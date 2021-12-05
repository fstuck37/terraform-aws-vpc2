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
