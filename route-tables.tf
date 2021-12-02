resource "aws_route_table" "pubrt" {
  for_each = {for az in var.zones[var.region] : az => az
    if contains(keys(var.subnets), var.pub_layer)
  }
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(
    var.tags,
    tomap({ "Name" = format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-pub-az-${element(split("-", each.value), length(split("-", each.value)) - 1)}") }),
    local.resource-tags["aws_route_table"]
  )
}

resource "aws_vpn_gateway_route_propagation" "pubrt" {
  for_each   = {for az in var.zones[var.region] : az => az
    if contains(keys(var.subnets), var.pub_layer) && var.enable_pub_route_propagation
  }
  vpn_gateway_id = aws_vpn_gateway.vgw.id
  route_table_id = aws_route_table.pubrt[each.value].id
}

resource "aws_route_table" "privrt" {
  for_each = {for az in var.zones[var.region] : az => az}
  vpc_id           = aws_vpc.main_vpc.id
  propagating_vgws = [aws_vpn_gateway.vgw.id]
  tags             = merge(
    var.tags,
    tomap({ "Name" = format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-prod-az-${element(split("-", each.value), length(split("-", each.value)) - 1)}")}),
    local.resource-tags["aws_route_table"]
  )
}

resource "aws_route_table_association" "associations" {
  for_each = {for i in local.subnet_data:i.name=>i}
  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = each.value.layer == var.pub_layer ? aws_route_table.pubrt[each.value.az].id : aws_route_table.privrt[each.value.az].id
}

  
