/* Module Specific */
output "vpc_id" {
  description = "string : The ID of the VPC"
  value       = aws_vpc.main_vpc.id
}

output "vpc_name" {
  description = "string : The name of the VPC"
  value       = format("%s", var.vpc-name == "null" ? "${var.name-vars["account"]}-${replace(var.region, "-", "")}-${var.name-vars["name"]}" : var.vpc-name)
}

output "subnet_ids" {
  description = "map(list(string)) : Map with keys the same as subnets and value list of subnet IDs"
  value       = local.subnet_ids
}

output "routetable_ids" {
  description = "map(list(string)) : "
  value       = local.routetable_ids
}

/* AWS Data Calls */
output "account_id" {
  description = "string : Account Number the VPC was deployed to."
  value       = data.aws_caller_identity.current.account_id
}

output "available_availability_zone" {
  description = "list(string) : List of teh available availability zones in the region."
  value       = data.aws_availability_zones.azs.names
}

/* Resource Direct */
output "aws_vpc" {
  description = "Resource aws_vpc - [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)"
  value       = aws_vpc.main_vpc
}

output "aws_internet_gateway" {
  description = "Resource aws_internet_gateway [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/internet_gateway)"
  value       = aws_internet_gateway.inet-gw
}

output "aws_s3_endpoint" {
  description = "Resource aws_vpc_endpoint for S3 [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)"
  value       = aws_vpc_endpoint.private-s3
}

output "aws_dynamodb_endpoint" {
  description = "Resource aws_vpc_endpoint for DynamoDB [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)"
  value       = aws_vpc_endpoint.private-dynamodb
}

output "aws_vpc_endpoint" {
  description = "Resource aws_vpc_endpoint for Interface Endpoints [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)"
  value       = aws_vpc_endpoint.private-interface-endpoints
}

output "aws_eip" {
  description = "Resource aws_eip [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)"
  value       = aws_eip.eip
}

output "aws_nat_gateway" {
  description = "Resource aws_nat_gateway [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)"
  value       = aws_nat_gateway.natgw
}

output "aws_vpc_dhcp_options" {
  description = "Resource aws_vpc_dhcp_options [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options)"
  value       = aws_vpc_dhcp_options.dhcp-opt
}

output "aws_customer_gateway" {
  description = "Resource aws_customer_gateway [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/customer_gateway)"
  value       = aws_customer_gateway.aws_customer_gateways
}

output "aws_vpn_connection" {
  description = "Resource aws_vpn_connection [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_connection)"
  value       = aws_vpn_connection.aws_vpn_connections
}

output "aws_vpn_gateway" {
  description = "Resource aws_vpn_gateway [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway)"
  value       = aws_vpn_gateway.vgw
}

output "aws_network_acl" {
  description = "Resource aws_network_acl [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl)"
  value       = aws_network_acl.net_acl
}

output "aws_vpc_peering_connection" {
  description = "Resource aws_vpc_peering_connection [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection)"
  value       = aws_vpc_peering_connection.peer
}

output "aws_vpc_peering_connection_accepter" {
  description = "Resource aws_vpc_peering_connection_accepter [see](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter)"
  value       = aws_vpc_peering_connection_accepter.peer
}

/* Local Data */
output "peerlink_accepter_routes" {
  description = "list(map(string)) : Data used to create routes for accepted peer links."
  value       = local.peerlink_accepter_routes
}

output "peerlink_requester_routes" {
  description = "list(map(string)) : Data used to create routes for requested peer links."
  value       = local.peerlink_requester_routes
}

output "subnet_data" {
  description = "list(object(...)) : Data used to create the subnets and other related items like routing tables."
  value       = local.subnet_data
}

output "nacl_rules" {
  description = "map(object(...)) : Data used to create the Public Subnet Network Access Control List."
  value       = local.nacl_rules
}

output "txgw_routes" {
  description = "list(map(string)) : Data used to create routes that point to the Transit Gateway."
  value       = local.txgw_routes
}

output "vpn_connection_routes" {
  description = "list(map(string)) : Data used to create static routes that point VPN connections."
  value       = local.vpn_connection_routes
}

output "route53_reverse_zones" {
  description = "list(string) : Data used to create Route53 reverse DNS zones."
  value       = local.route53_reverse_zones
}