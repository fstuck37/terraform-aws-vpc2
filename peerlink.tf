resource "aws_vpc_peering_connection" "peer" {
  for_each      = var.peer_requester
    vpc_id        = aws_vpc.main_vpc.id
    peer_vpc_id   = each.value.peer_vpc_id
    peer_owner_id = each.value.peer_owner_id
    auto_accept   = var.acctnum == each.value.peer_owner_id ? true : false

    requester {
      allow_classic_link_to_remote_vpc = false
      allow_remote_vpc_dns_resolution  = each.value.allow_remote_vpc_dns_resolution
      allow_vpc_to_remote_classic_link = false
    }
    tags = merge(
      var.tags,
      tomap({ "Name" = "${each.key}-peerlink"})
    )
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  for_each                  = var.peer_accepter
    vpc_peering_connection_id = each.value.vpc_peering_connection_id
    auto_accept               = true

    accepter {
      allow_classic_link_to_remote_vpc = false
      allow_remote_vpc_dns_resolution  = each.value.allow_remote_vpc_dns_resolution
      allow_vpc_to_remote_classic_link = false
    }

    tags = merge(
      var.tags,
      tomap({ "Name" = "${each.key}-peerlink"})
    )
}

/*
need to finish local route list to loop through
resource "aws_route" "accepter_routes" {
  for_each                  = {for route in local.peerlink_accepter_routes : route.name => route}
    route_table_id            = each.value.route_table
    destination_cidr_block    = each.value.cidr
    vpc_peering_connection_id = each.value.conn_id
}

resource "aws_route" "requester_routes" {
  for_each                  = {for route in local.peerlink_requester_routes : route.name => route}
    route_table_id            = each.value.route_table
    destination_cidr_block    = each.value.cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peer[each.value.peer_link_name].id
 }
*/