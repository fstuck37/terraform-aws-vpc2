output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main_vpc.id
}

output "vpc_name" {
  description = "The name of the VPC"
  value = "${format("%s", var.vpc-name == true ? "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" : var.vpc-name)}"
}

output "subnet_ids" {
  description = "Map with keys the same as subnets and value list of subnet IDs"
  value = local.subnet_ids
}

output "peerlink_accepter_routes" {
  value = local.peerlink_accepter_routes
}

output "peerlink_requester_routes" {
  value = local.peerlink_requester_routes
}

output "routetable_ids" {
  value = local.routetable_ids
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "available_availability_zone" {
  value = data.aws_availability_zones.azs.names
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.inet-gw
}

output "aws_s3_endpoint" {
  value = aws_vpc_endpoint.private-s3
}

output "aws_dynamodb_endpoint" {
  value = aws_vpc_endpoint.private-dynamodb
}

output "aws_eip" {
  value = aws_eip.eip
}

output "aws_nat_gateway" {
  value = aws_nat_gateway.natgw
}

output "aws_vpc_dhcp_options" {
  value = aws_vpc_dhcp_options.dhcp-opt
}

output "aws_customer_gateway" {
  value = aws_customer_gateway.aws_customer_gateways
}

output "aws_vpn_connection" {
  value = aws_vpn_connection.aws_vpn_connections
}

output "aws_vpn_gateway" {
  value = aws_vpn_gateway.vgw
}

output "aws_network_acl" {
  value = aws_network_acl.net_acl
}

output "aws_vpc_endpoint" {
  value = aws_vpc_endpoint.private-interface-endpoints
}

output "aws_vpc_peering_connection" {
  value = aws_vpc_peering_connection.peer
}

output "aws_vpc_peering_connection_accepter" {
  value = aws_vpc_peering_connection_accepter.peer
}





