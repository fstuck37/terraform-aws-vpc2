resource "aws_dx_gateway_association" "aws_dx_gateway_association" {
  for_each = { for dxgw in [var.dx_gateway_id] : dxgw => dxgw
  if var.dx_gateway_id != "null" }
  dx_gateway_id         = each.value
  associated_gateway_id = aws_vpn_gateway.vgw[var.region]
}