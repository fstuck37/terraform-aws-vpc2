resource "aws_nat_gateway" "natgw" {
  for_each = { for sd in local.subnet_data : sd.az => sd
  if sd.layer == var.pub_layer && var.deploy_natgateways }
  allocation_id = aws_eip.eip[each.value.az].id
  subnet_id     = aws_subnet.subnets[each.value.name].id

  tags = merge(
    var.tags,
    tomap({ "Name" = each.value.name }),
    local.resource-tags["aws_nat_gateway"]
  )
}