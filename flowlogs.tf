resource "aws_flow_log" "vpc_flowlog" {
  for_each = { for fl in [var.region] : fl => fl
  if var.enable_flowlog }
  vpc_id                   = aws_vpc.main_vpc.id
  log_destination          = local.flow_log_destination_arn
  iam_role_arn             = local.flow_log_iam_role_arn
  traffic_type             = var.flow_log_traffic_type
  max_aggregation_interval = var.flow_log_max_aggregation_interval
  log_format               = var.flow_log_format
  log_destination_type     = var.flow_log_destination_type

  dynamic "destination_options" {
    for_each = var.flow_log_destination_type == "s3" ? [var.region] : []
    content {
      file_format                = var.flow_log_file_format
      hive_compatible_partitions = var.flow_log_hive_compatible_partitions
      per_hour_partition         = var.flow_log_per_hour_partition
    }
  }

  tags = merge(
    var.tags,
    tomap({ "Name" = each.key }),
    local.resource-tags["aws_flow_log"]
  )
}



/* need to send logs to Cloud Watch */
resource "aws_cloudwatch_log_group" "flowlog_group" {
  for_each = { for fl in [var.region] : fl => fl
  if var.enable_flowlog && var.flow_log_destination_type == "cloud-watch-logs" }
  name              = aws_vpc.main_vpc.id
  retention_in_days = var.cloudwatch_retention_in_days
  tags = merge(
    var.tags,
    tomap({ "Name" = each.key }),
    local.resource-tags["aws_cloudwatch_log_group"]
  )
}

resource "aws_iam_role" "flowlog_role" {
  for_each = { for fl in ["${var.name-vars["account"]}-${replace(var.region, "-", "")}-${var.name-vars["name"]}-flow-log-role"] : fl => fl
  if var.enable_flowlog && var.flow_log_destination_type == "cloud-watch-logs" }
  name               = "${var.name-vars["account"]}-${replace(var.region, "-", "")}-${var.name-vars["name"]}-flow-log-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF
}

resource "aws_iam_role_policy" "flowlog_write" {
  for_each = { for fl in ["${var.name-vars["account"]}-${replace(var.region, "-", "")}-${var.name-vars["name"]}-flow-log-role"] : fl => fl
  if var.enable_flowlog && var.flow_log_destination_type == "cloud-watch-logs" }
  name   = "${var.name-vars["account"]}-${replace(var.region, "-", "")}-${var.name-vars["name"]}-write-to-cloudwatch"
  role   = aws_iam_role.flowlog_role["${var.name-vars["account"]}-${replace(var.region, "-", "")}-${var.name-vars["name"]}-flow-log-role"].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}   
EOF
}




/* only needed if sending to lambda */
resource "aws_cloudwatch_log_subscription_filter" "flow_logs_lambda" {
  for_each = { for fl in ["${var.aws_lambda_function_name}-logfilter"] : fl => fl
  if var.enable_flowlog && !(var.aws_lambda_function_name == "null") && var.flow_log_destination_type == "cloud-watch-logs" }
  name            = "${var.aws_lambda_function_name}-logfilter"
  log_group_name  = aws_cloudwatch_log_group.flowlog_group[var.region].name
  filter_pattern  = var.flow_log_filter
  destination_arn = "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.aws_lambda_function_name}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  for_each = { for fl in ["${var.aws_lambda_function_name}-logfilter"] : fl => fl
  if var.enable_flowlog && !(var.aws_lambda_function_name == "null") && var.flow_log_destination_type == "cloud-watch-logs" }
  statement_id   = "AllowExecutionFromCloudWatch_${aws_vpc.main_vpc.id}"
  action         = "lambda:InvokeFunction"
  function_name  = var.aws_lambda_function_name
  principal      = "logs.${var.region}.${var.amazonaws-com}"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = length(regexall(".*cn-.*", var.region)) > 0 ? "arn:aws-cn:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_vpc.main_vpc.id}:*" : "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_vpc.main_vpc.id}:*"
}
