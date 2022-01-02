resource "aws_eip" "eip" {
  for_each = { for sd in local.subnet_data : sd.az => sd
  if sd.layer == var.pub_layer && var.deploy_natgateways }
  vpc = true
}
