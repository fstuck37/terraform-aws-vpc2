resource "aws_internet_gateway" "inet-gw" {
  for_each = { for i in [var.region] : i => i
  if contains(keys(var.subnets), var.pub_layer) }
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.tags,
    tomap({ "Name" = each.value }),
    local.resource-tags["aws_internet_gateway"]
  )
}