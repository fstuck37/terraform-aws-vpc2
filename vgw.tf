resource "aws_vpn_gateway" "vgw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(
    var.tags,
    tomap({ "Name" = format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-vgw") }),
    local.resource-tags["aws_vpn_gateway"]
  )
}