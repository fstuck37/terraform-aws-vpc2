resource "aws_subnet" "subnets" {
  for_each = {for i in local.subnet_data:i.name=>i}
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = each.value.subnet_cidr
  availability_zone = each.value.az
  tags              = merge(
    var.tags, 
    tomap({"Name" = each.value.name}),
    local.subnet-tags[each.value.layer],
    local.resource-tags["aws_subnet"]
  )
  lifecycle {
    ignore_changes = var.subnets_ignore_changes
  }
}





data "template_file" "subnets-tags" {
  count    = length(var.subnets)*local.num-availbility-zones
  template = "${format("%02s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${element(local.subnet-order,local.subnets-list[count.index])}-az-${element(split("-", element(var.zones[var.region],local.azs-list[count.index])), length(split("-", element(var.zones[var.region],local.azs-list[count.index]))) - 1)}")}"
}


resource "aws_subnet" "gwep" {
  count             = var.deploy_gwep && !(var.egress_only_internet_gateway) ? local.num-availbility-zones : 0
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(var.gwep_subnet,ceil(log(length(var.zones[var.region]),2)),count.index)
  availability_zone = element(var.zones[var.region],count.index)
  tags              = merge(
    var.tags, 
    tomap({ "Name" = format("%02s", "${var.name-vars["account"]}-${var.name-vars["name"]}-gwep-az-${element(split("-", element(var.zones[var.region],local.azs-list[count.index])), length(split("-", element(var.zones[var.region],local.azs-list[count.index]))) - 1)}") }),
    local.subnet-tags["${element(local.subnet-order,local.subnets-list[count.index])}"],
    local.resource-tags["aws_subnet"]
  )

  lifecycle {
    ignore_changes = [tags]
  }
}



