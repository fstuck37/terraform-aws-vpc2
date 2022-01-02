resource "aws_ec2_transit_gateway_vpc_attachment" "txgw_attachment" {
  for_each = { for txgw in [var.transit_gateway_id] : txgw => txgw
  if var.transit_gateway_id != "null" }
  subnet_ids = [for i in local.subnet_data : aws_subnet.subnets[i.name].id
  if i.layer == var.txgw_layer]
  transit_gateway_id     = var.transit_gateway_id
  vpc_id                 = aws_vpc.main_vpc.id
  appliance_mode_support = var.appliance_mode_support
}

resource "aws_route" "txgw-routes" {
  for_each               = { for item in local.txgw_routes : item.name => item }
  route_table_id         = aws_route_table.privrt[each.value.az].id
  destination_cidr_block = each.value.route
  transit_gateway_id     = var.transit_gateway_id
}

