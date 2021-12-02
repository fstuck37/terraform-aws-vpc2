resource "aws_internet_gateway" "inet-gw" {
  for_each = { for i in [format("%s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${replace(var.region,"-", "")}-igw" )] : i=>i
           if contains( keys(var.subnets), var.pub_layer) }
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.tags,
    tomap({ "Name" = each.value}),
    local.resource-tags["aws_internet_gateway"]
  )
}




