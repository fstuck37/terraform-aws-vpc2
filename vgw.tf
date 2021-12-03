resource "aws_vpn_gateway" "vgw" {
  for_each = { for vgw in [var.region]: vgw => vgw
               if var.enable_vpn_gateway }
  tags   = merge(
    var.tags,
    tomap({ "Name" = format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-vgw") }),
    local.resource-tags["aws_vpn_gateway"]
  )
}
