resource "aws_vpc_endpoint" "private-s3" {
  for_each = {for s3 in ["com.amazonaws.${var.region}.s3"] : s3 => s3
    if var.enable-s3-endpoint
  }
    vpc_id          = aws_vpc.main_vpc.id
    service_name    = "com.amazonaws.${var.region}.s3"
    route_table_ids = [for rt in aws_route_table.privrt : rt.id]
}

resource "aws_vpc_endpoint" "private-dynamodb" {
  for_each = {for db in ["com.amazonaws.${var.region}.dynamodb"] : db => db
    if var.enable-dynamodb-endpoint
  }
    vpc_id          = aws_vpc.main_vpc.id
    service_name    = "com.amazonaws.${var.region}.dynamodb"
    route_table_ids = [for rt in aws_route_table.privrt : rt.id]
}





/*

resource "aws_vpc_endpoint" "private-interface-endpoints" {
  for_each                  = {for endpoint in var.private_endpoints : endpoint.name => endpoint}
  vpc_id                    = aws_vpc.main_vpc.id
  service_name              = replace(each.value.service, "<REGION>", var.region)
  private_dns_enabled       = lookup(each.value, "private_dns_enabled", true)
  vpc_endpoint_type         = "Interface"
  subnet_ids                = zipmap(var.subnet-order, chunklist(aws_subnet.subnets.*.id, local.num-availbility-zones))[each.value.subnet]
  security_group_ids        = compact(split("|", each.value.security_group))
 
  tags                      = merge(
    var.tags,
    tomap({ "Name" = each.value.name }),
    local.resource-tags[each.value.name]
  )


}

resource "aws_vpc_endpoint" "GatewayEndPoint" {
  count  = var.deploy_gwep && !(var.egress_only_internet_gateway) ? local.num-availbility-zones : 0
  vpc_id            = aws_vpc.main_vpc.id
  vpc_endpoint_type = "GatewayLoadBalancer"
  subnet_ids        = [aws_subnet.gwep.*.id[count.index]]
  service_name      = var.gwep_service_name
}
*/