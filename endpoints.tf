resource "aws_vpc_endpoint" "private-s3" {
  for_each = { for s3 in ["com.amazonaws.${var.region}.s3"] : s3 => s3
  if var.enable-s3-endpoint }
  vpc_id          = aws_vpc.main_vpc.id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = [for rt in aws_route_table.privrt : rt.id]
}

resource "aws_vpc_endpoint" "private-dynamodb" {
  for_each = { for db in ["com.amazonaws.${var.region}.dynamodb"] : db => db
  if var.enable-dynamodb-endpoint }
  vpc_id          = aws_vpc.main_vpc.id
  service_name    = "com.amazonaws.${var.region}.dynamodb"
  route_table_ids = [for rt in aws_route_table.privrt : rt.id]
}

resource "aws_vpc_endpoint" "private-interface-endpoints" {
  for_each            = { for endpoint in var.private_endpoints : replace(endpoint.name, "<REGION>", var.region) => endpoint }
  vpc_id              = aws_vpc.main_vpc.id
  service_name        = replace(each.value.service, "<REGION>", var.region)
  private_dns_enabled = each.value.private_dns_enabled
  vpc_endpoint_type   = "Interface"
  subnet_ids = concat([for i in local.subnet_data : aws_subnet.subnets[i.name].id if contains(each.value.subnets, i.layer)],
  [for i in aws_subnet.subnets : i.id if contains(each.value.subnets, i.id)])
  security_group_ids = each.value.security_groups
  tags = merge(
    var.tags,
    tomap({ "Name" = replace(each.value.name, "<REGION>", var.region) }),
    local.resource-tags[each.value.name]
  )
}




