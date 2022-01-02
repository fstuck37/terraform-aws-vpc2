resource "aws_vpn_gateway" "vgw" {
  for_each = { for vgw in [var.region] : vgw => vgw
  if var.enable_vpn_gateway }
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.tags,
    tomap({ "Name" = format("%s", "${var.name-vars["account"]}-${var.name-vars["name"]}-vgw") }),
    local.resource-tags["aws_vpn_gateway"]
  )
}
