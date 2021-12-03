resource "aws_customer_gateway" "aws_customer_gateways" {
  for_each = { for key, value in var.vpn_connections : key => value
               if var.enable_vpn_gateway }
    type       = "ipsec.1"
    bgp_asn    = merge(var.default_vpn_connections, each.value).bgp_asn
    ip_address = merge(var.default_vpn_connections, each.value).peer_ip_address
    tags = merge(
      var.tags,
      tomap({ "Name" = each.key}),
      merge(var.default_vpn_connections, each.value).tags
    )
}

resource "aws_vpn_connection" "aws_vpn_connections" {
  for_each = { for key, value in var.vpn_connections : key => value
               if var.enable_vpn_gateway }
    type                  = "ipsec.1"
    vpn_gateway_id        = aws_vpn_gateway.vgw[var.region].id
    customer_gateway_id   = aws_customer_gateway.aws_customer_gateways[each.key].id
    static_routes_only    = merge(var.default_vpn_connections, each.value).static_routes_only
    tunnel1_inside_cidr   = merge(var.default_vpn_connections, each.value).tunnel1_inside_cidr == "" ? null : merge(var.default_vpn_connections, each.value).tunnel1_inside_cidr
    tunnel1_preshared_key = merge(var.default_vpn_connections, each.value).tunnel1_preshared_key == "" ? null : merge(var.default_vpn_connections, each.value).tunnel1_preshared_key
    tunnel2_inside_cidr   = merge(var.default_vpn_connections, each.value).tunnel2_inside_cidr == "" ? null : merge(var.default_vpn_connections, each.value).tunnel2_inside_cidr
    tunnel2_preshared_key = merge(var.default_vpn_connections, each.value).tunnel2_preshared_key == "" ? null : merge(var.default_vpn_connections, each.value).tunnel2_preshared_key
    tags = merge(
      var.tags,
      tomap({ "Name" = each.key}),
      merge(var.default_vpn_connections, each.value).tags
    )
}

resource "aws_vpn_connection_route" "aws_vpn_connection_routes" {
  for_each = {for rt in local.vpn_connection_routes : rt.name => rt 
              if var.enable_vpn_gateway }
  vpn_connection_id      = aws_vpn_connection.aws_vpn_connections[each.value.name].id
  destination_cidr_block = each.value.cidr
}