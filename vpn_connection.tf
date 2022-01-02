resource "aws_customer_gateway" "aws_customer_gateways" {
  for_each = { for key, value in var.vpn_connections : key => value
  if var.enable_vpn_gateway }

  type        = "ipsec.1"
  bgp_asn     = merge(var.default_vpn_connections, each.value).bgp_asn
  device_name = merge(var.default_vpn_connections, each.value).device_name
  ip_address  = merge(var.default_vpn_connections, each.value).peer_ip_address

  tags = merge(
    var.tags,
    tomap({ "Name" = each.key }),
    merge(var.default_vpn_connections, each.value).tags
  )
}

resource "aws_vpn_connection" "aws_vpn_connections" {
  for_each = { for key, value in var.vpn_connections : key => value
  if var.enable_vpn_gateway }
  type                = "ipsec.1"
  vpn_gateway_id      = aws_vpn_gateway.vgw[var.region].id
  customer_gateway_id = aws_customer_gateway.aws_customer_gateways[each.key].id

  static_routes_only       = merge(var.default_vpn_connections, each.value).static_routes_only
  local_ipv4_network_cidr  = merge(var.default_vpn_connections, each.value).local_ipv4_network_cidr
  remote_ipv4_network_cidr = merge(var.default_vpn_connections, each.value).remote_ipv4_network_cidr
  tunnel_inside_ip_version = merge(var.default_vpn_connections, each.value).tunnel_inside_ip_version

  tunnel1_inside_cidr                  = merge(var.default_vpn_connections, each.value).tunnel1_inside_cidr
  tunnel1_preshared_key                = merge(var.default_vpn_connections, each.value).tunnel1_preshared_key
  tunnel1_dpd_timeout_action           = merge(var.default_vpn_connections, each.value).tunnel1_dpd_timeout_action
  tunnel1_dpd_timeout_seconds          = merge(var.default_vpn_connections, each.value).tunnel1_dpd_timeout_seconds
  tunnel1_ike_versions                 = merge(var.default_vpn_connections, each.value).tunnel1_ike_versions
  tunnel1_phase1_dh_group_numbers      = merge(var.default_vpn_connections, each.value).tunnel1_phase1_dh_group_numbers
  tunnel1_phase1_encryption_algorithms = merge(var.default_vpn_connections, each.value).tunnel1_phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms  = merge(var.default_vpn_connections, each.value).tunnel1_phase1_integrity_algorithms
  tunnel1_phase1_lifetime_seconds      = merge(var.default_vpn_connections, each.value).tunnel1_phase1_lifetime_seconds
  tunnel1_phase2_dh_group_numbers      = merge(var.default_vpn_connections, each.value).tunnel1_phase2_dh_group_numbers
  tunnel1_phase2_encryption_algorithms = merge(var.default_vpn_connections, each.value).tunnel1_phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms  = merge(var.default_vpn_connections, each.value).tunnel1_phase2_integrity_algorithms
  tunnel1_phase2_lifetime_seconds      = merge(var.default_vpn_connections, each.value).tunnel1_phase2_lifetime_seconds
  tunnel1_rekey_fuzz_percentage        = merge(var.default_vpn_connections, each.value).tunnel1_rekey_fuzz_percentage
  tunnel1_rekey_margin_time_seconds    = merge(var.default_vpn_connections, each.value).tunnel1_rekey_margin_time_seconds
  tunnel1_replay_window_size           = merge(var.default_vpn_connections, each.value).tunnel1_replay_window_size
  tunnel1_startup_action               = merge(var.default_vpn_connections, each.value).tunnel1_startup_action

  tunnel2_inside_cidr                  = merge(var.default_vpn_connections, each.value).tunnel2_inside_cidr
  tunnel2_preshared_key                = merge(var.default_vpn_connections, each.value).tunnel2_preshared_key
  tunnel2_dpd_timeout_action           = merge(var.default_vpn_connections, each.value).tunnel2_dpd_timeout_action
  tunnel2_dpd_timeout_seconds          = merge(var.default_vpn_connections, each.value).tunnel2_dpd_timeout_seconds
  tunnel2_ike_versions                 = merge(var.default_vpn_connections, each.value).tunnel2_ike_versions
  tunnel2_phase1_dh_group_numbers      = merge(var.default_vpn_connections, each.value).tunnel2_phase1_dh_group_numbers
  tunnel2_phase1_encryption_algorithms = merge(var.default_vpn_connections, each.value).tunnel2_phase1_encryption_algorithms
  tunnel2_phase1_integrity_algorithms  = merge(var.default_vpn_connections, each.value).tunnel2_phase1_integrity_algorithms
  tunnel2_phase1_lifetime_seconds      = merge(var.default_vpn_connections, each.value).tunnel2_phase1_lifetime_seconds
  tunnel2_phase2_dh_group_numbers      = merge(var.default_vpn_connections, each.value).tunnel2_phase2_dh_group_numbers
  tunnel2_phase2_encryption_algorithms = merge(var.default_vpn_connections, each.value).tunnel2_phase2_encryption_algorithms
  tunnel2_phase2_integrity_algorithms  = merge(var.default_vpn_connections, each.value).tunnel2_phase2_integrity_algorithms
  tunnel2_phase2_lifetime_seconds      = merge(var.default_vpn_connections, each.value).tunnel2_phase2_lifetime_seconds
  tunnel2_rekey_fuzz_percentage        = merge(var.default_vpn_connections, each.value).tunnel2_rekey_fuzz_percentage
  tunnel2_rekey_margin_time_seconds    = merge(var.default_vpn_connections, each.value).tunnel2_rekey_margin_time_seconds
  tunnel2_replay_window_size           = merge(var.default_vpn_connections, each.value).tunnel2_replay_window_size
  tunnel2_startup_action               = merge(var.default_vpn_connections, each.value).tunnel2_startup_action

  tags = merge(
    var.tags,
    tomap({ "Name" = each.key }),
    merge(var.default_vpn_connections, each.value).tags
  )
}

resource "aws_vpn_connection_route" "aws_vpn_connection_routes" {
  for_each = { for rt in local.vpn_connection_routes : rt.name => rt
  if var.enable_vpn_gateway }
  vpn_connection_id      = aws_vpn_connection.aws_vpn_connections[each.value.vpn_name].id
  destination_cidr_block = each.value.cidr
}
