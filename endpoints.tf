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

resource "aws_vpc_endpoint" "private-interface-endpoints" {
  for_each                  = {for endpoint in var.private_endpoints : endpoint.name => endpoint}
    vpc_id                    = aws_vpc.main_vpc.id
    service_name              = replace(each.value.service, "<REGION>", var.region)
    private_dns_enabled       = each.value.private_dns_enabled
    vpc_endpoint_type         = "Interface"
    subnet_ids                = [for i in local.subnet_data : aws_subnet.subnets[i.name].id
                                 if contains(each.value.subnets, i.layer) ]
    security_group_ids        = each.value.security_groups
    tags                      = merge(
      var.tags,
      tomap({ "Name" = each.value.name }),
      local.resource-tags[each.value.name]
    )
}






    


/*
resource "aws_vpc_endpoint" "GatewayEndPoint" {
  count  = var.deploy_gwep && !(var.egress_only_internet_gateway) ? local.num-availbility-zones : 0
  vpc_id            = aws_vpc.main_vpc.id
  vpc_endpoint_type = "GatewayLoadBalancer"
  subnet_ids        = [aws_subnet.gwep.*.id[count.index]]
  service_name      = var.gwep_service_name
}
*/