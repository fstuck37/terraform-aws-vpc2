locals {
  emptymaps = [{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]
  resource_list = ["aws_vpc", "aws_vpn_gateway", "aws_subnet", "aws_network_acl", "aws_internet_gateway", "aws_cloudwatch_log_group", "aws_vpc_dhcp_options", "aws_route_table", "aws_route53_resolver_endpoint", "aws_lb", "aws_flow_log", "aws_nat_gateway"]
  private_endpoints_names = [for endpoint in var.private_endpoints : endpoint.name]
  empty-resource-tags = zipmap( distinct(concat(local.private_endpoints_names,local.resource_list)), slice(local.emptymaps, 0 ,length(distinct(concat(local.private_endpoints_names,local.resource_list)))) )
  resource-tags = merge(local.empty-resource-tags, var.resource-tags)

  subnet_data = flatten([
    for i, sn in keys(var.subnets) : [
      for ii, az in var.zones[var.region] : {
        az              = az
        layer           = sn
        name            = format("%02s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${sn}-${element(split("-", az), length(split("-", az )) - 1)}")
        index           = (i*length(var.zones[var.region]))+ii
        layer_index     = i
        subnet_index    = ii
        layer_cidr      = var.subnets[sn]
        layer_cidr_size = element(split("/", var.subnets[sn]),1)
        azs_allocated   = pow(2,ceil(log(max(var.reserve_azs, length(var.zones[var.region])),2)))
        subnet_cidr     = cidrsubnet(   var.subnets[sn] , ceil(log( max(var.reserve_azs, length(var.zones[var.region])) ,2 )) , ii )
        subnet-tags     = merge(
                                 var.tags ,
                                 tomap({"Name" = format("%02s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${sn}-${element(split("-", az), length(split("-", az )) - 1)}") }) , 
                                 local.subnet-tags[sn] , local.resource-tags["aws_subnet"] 
                          )
      }]
    ])

  subnet-order = coalescelist( var.subnet-order, keys(var.subnets))
  empty-subnet-tags = zipmap(local.subnet-order, slice(local.emptymaps, 0 ,length(local.subnet-order)))
  subnet-tags = merge(local.empty-subnet-tags,var.subnet-tags)
  
  nacl_rules = merge(
    {for i, rule in var.block_tcp_ports : "tcp-e-${rule}" => {
        rule_number         = 32700-(i*100)
        egress              = true
        protocol            = "tcp"
        rule_action         = "deny"
        cidr_block          = "0.0.0.0/0"
        from_port           = length(split("-", rule)) < 2 ? rule : element(split("-", rule), 0)
        to_port             = length(split("-", rule)) < 2 ? rule : element(split("-", rule), 1)
      }
    },
    {for i, rule in var.block_udp_ports : "udp-e-${rule}" => {
        rule_number         = 32700-(i*100)-(length(var.block_tcp_ports)*100)
        egress              = true
        protocol            = "udp"
        rule_action         = "deny"
        cidr_block          = "0.0.0.0/0"
        from_port           = length(split("-", rule)) < 2 ? rule : element(split("-", rule), 0)
        to_port             = length(split("-", rule)) < 2 ? rule : element(split("-", rule), 1)
      }
    },
    {for i, rule in var.block_tcp_ports : "tcp-i-${rule}" => {
        rule_number         = 32700-(i*100)
        egress              = false
        protocol            = "tcp"
        rule_action         = "deny"
        cidr_block          = "0.0.0.0/0"
        from_port           = length(split("-", rule)) < 2 ? rule : element(split("-", rule), 0)
        to_port             = length(split("-", rule)) < 2 ? rule : element(split("-", rule), 1)
      }
    },
    {for i, rule in var.block_udp_ports : "udp-i-${rule}" => {
        rule_number         = 32700-(i*100)-(length(var.block_tcp_ports)*100)
        egress              = false
        protocol            = "udp"
        rule_action         = "deny"
        cidr_block          = "0.0.0.0/0"
        from_port           = length(split("-", rule)) < 2 ? rule : element(split("-", rule), 0)
        to_port             = length(split("-", rule)) < 2 ? rule : element(split("-", rule), 1)
      }
    },
    var.network_acl_rules
  )

  txgw_routes = flatten([
  for rt in var.transit_gateway_routes : [
    for az in var.zones[var.region] : {
      name        = "${az}-${rt}"
      route       = rt
      az          = az
    }
    if var.transit_gateway_id != "null"]
  ])

  peerlink_accepter_routes = flatten([
    for az in var.zones[var.region] : [
      for key, value in var.peer_accepter : [
        for cidr in value.peer_cidr_blocks : {
          name                      = "${az}-${replace(cidr, "/", "-")}" 
          peer_link_name            = key
          az                        = az
          vpc_peering_connection_id = value.vpc_peering_connection_id
          cidr                      = cidr
        }
      ]
    ]
  ])

  peerlink_requester_routes = flatten([
    for az in var.zones[var.region] : [
      for key, value in var.peer_requester : [
        for cidr in value.peer_cidr_blocks : {
          name           = "${az}-${replace(cidr, "/", "-")}" 
          peer_link_name = key
          az             = az
          cidr           = cidr
        }
      ]
    ]
  ])

  vpn_connection_routes = flatten([
    for az in var.zones[var.region] : [
      for vpn, value in var.vpn_connections : [
        for cidr in merge(var.default_vpn_connections, var.vpn_connections[vpn]).destination_cidr_blocks : {
          name           = "${az}-${replace(cidr, "/", "-")}" 
          vpn_name       = vpn
          az             = az
          cidr           = cidr
        }
      ]
    ]
  ])

  route53-reverse-zones = flatten([
    for cidr in var.vpc-cidrs : [
      for n in range(pow(2,(24 - tonumber(element(split("/", cidr), 1))))) : [
        cidrsubnet(cidr, (24 - tonumber(element(split("/", cidr), 1))), n)
      ]
    if tonumber(element(split("/", cidr), 1)) <= 24 ]
  ])



  subnet_ids = {
    for layer in keys(var.subnets) :
      layer => [
        for sd in local.subnet_data: 
          aws_subnet.subnets[sd.name].id
      if sd.layer == layer ]
  }
  
  subnet_cidrs = {
    for layer in keys(var.subnets) :
      layer => [
        for sd in local.subnet_data: 
          aws_subnet.subnets[sd.name].cidr_block
      if sd.layer == layer ]
  }

  routetable_ids = {
    for layer in keys(var.subnets) :
      layer => distinct([
        for sd in local.subnet_data:
          sd.layer == var.pub_layer ? aws_route_table.pubrt[sd.az].id : aws_route_table.privrt[sd.az].id
      if sd.layer == layer ])
  }
}


