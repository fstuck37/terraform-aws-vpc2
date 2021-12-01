output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main_vpc.id
}

output "vpc_name" {
  description = "The name of the VPC"
  value = "${format("%s", var.vpc-name == true ? "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" : var.vpc-name)}"
}

output "subnet_ids" {
  description = "Map with keys based on the subnet names and values of subnet IDs"
  value = {}
}

output "map_subnet_id_list" {
  description = "Map with keys the same as subnet-order and values a list of subnet IDs"
  value = {}
}

