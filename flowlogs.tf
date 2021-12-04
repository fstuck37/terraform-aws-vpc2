resource "aws_flow_log" "vpc_flowlog" {
  for_each = {for fl in [var.region] : fl => fl
              if var.enable_flowlog }
    vpc_id = aws_vpc.main_vpc.id
    log_destination = aws_cloudwatch_log_group.flowlog_group[var.region].arn
    iam_role_arn = aws_iam_role.flowlog_role["${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-flow-log-role"].arn
    traffic_type = "ALL"
    log_format = var.flow_log_format
    tags   = merge(
      var.tags,
      tomap({ "Name" = each.key}),
      local.resource-tags["aws_flow_log"]
    )
}

resource "aws_cloudwatch_log_group" "flowlog_group" {
  for_each = {for fl in [var.region] : fl => fl
              if var.enable_flowlog }
    name = aws_vpc.main_vpc.id
    retention_in_days = var.cloudwatch_retention_in_days
    tags = merge(
      var.tags,
      tomap({ "Name" = each.key}),
      local.resource-tags["aws_cloudwatch_log_group"]
      )
}

resource "aws_iam_role" "flowlog_role" {
  for_each = {for fl in ["${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-flow-log-role"] : fl => fl
              if var.enable_flowlog }
    name = "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-flow-log-role"
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
  for_each = {for fl in ["${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-flow-log-role"] : fl => fl
              if var.enable_flowlog }
  name = "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-write-to-cloudwatch"
  role = aws_iam_role.flowlog_role["${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-flow-log-role"].id
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

resource "aws_iam_role" "flowlog_subscription_role" {
  for_each = {for fl in ["${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-flow-log-subscription-role"] : fl => fl
              if var.enable_flowlog }
    name = "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-flow-log-subscription-role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${var.region}.${var.amazonaws-com}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF
}

resource "aws_cloudwatch_log_subscription_filter" "flow_logs_lambda" {
  for_each = {for fl in ["${var.aws_lambda_function_name}-logfilter"] : fl => fl
              if var.enable_flowlog && !(var.aws_lambda_function_name == "null" ) }
    name = "${var.aws_lambda_function_name}-logfilter"
    log_group_name = aws_cloudwatch_log_group.flowlog_group[var.region].name
    filter_pattern = var.flow_log_filter
    destination_arn = "arn:aws:lambda:${var.region}:${var.acctnum}:function:${var.aws_lambda_function_name}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  for_each = {for fl in ["${var.aws_lambda_function_name}-logfilter"] : fl => fl
              if var.enable_flowlog && !(var.aws_lambda_function_name == "null" ) }
    statement_id   = "AllowExecutionFromCloudWatch_${aws_vpc.main_vpc.id}"
    action         = "lambda:InvokeFunction"
    function_name  = var.aws_lambda_function_name
    principal      = "logs.${var.region}.${var.amazonaws-com}"
    source_account = var.acctnum
    source_arn     = length(regexall(".*cn-.*", var.region)) > 0 ? "arn:aws-cn:logs:${var.region}:${var.acctnum}:log-group:${aws_vpc.main_vpc.id}:*" : "arn:aws:logs:${var.region}:${var.acctnum}:log-group:${aws_vpc.main_vpc.id}:*"
}
