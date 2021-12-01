resource "aws_route_table" "pubrt" {
  for_each = {for az in var.zones[var.region] : az => az
    if contains(keys(var.subnets), var.pub_layer)
  }
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(
    var.tags,
    tomap({ "Name" = format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-pub-az-${element(split("-", element(var.zones[var.region],count.index)), length(split("-", element(var.zones[var.region],count.index))) - 1)}") }),
    local.resource-tags["aws_route_table"]
  )
}

resource "aws_vpn_gateway_route_propagation" "pubrt" {
  for_each   = {for az in var.zones[var.region] : az => az
    if contains(keys(var.subnets), var.pub_layer) && var.enable_pub_route_propagation
  }
  vpn_gateway_id = aws_vpn_gateway.vgw.id
  route_table_id = aws_route_table.pubrt[each.value].id
}

resource "aws_route_table" "privrt" {
  for_each = {for az in var.zones[var.region] : az => az}
  vpc_id           = aws_vpc.main_vpc.id
  propagating_vgws = [aws_vpn_gateway.vgw.id]
  tags             = merge(
    var.tags,
    tomap({ "Name" = format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-prod-az-${element(split("-", element(var.zones[var.region],count.index)), length(split("-", element(var.zones[var.region],count.index))) - 1)}")}),
    local.resource-tags["aws_route_table"]
  )
}

resource "aws_route_table_association" "associations" {
  for_each = {for az in var.zones[var.region] : az => az}
  subnet_id      = aws_subnet.subnets[each.value].id
  route_table_id = aws_route_table.privrt[each.value].id
}


/*
resource "aws_route" "privrt-gateway" {
  count                  = !contains(keys(var.subnets), var.pub_layer)  || !var.deploy_natgateways || var.dx_bgp_default_route ? 0 : local.num-availbility-zones
  route_table_id         = aws_route_table.privrt.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.*.id[count.index]
}

resource "aws_route" "pub-default" {
  count                  = contains(keys(var.subnets), var.pub_layer) && !var.deploy_gwep && !var.egress_only_internet_gateway ? 1 : 0
  route_table_id         = join("",aws_route_table.pubrt.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inet-gw.0.id
}

resource "aws_route" "pub-default-gwep" {
  count                  = contains(keys(var.subnets), var.pub_layer) && var.deploy_gwep && !var.egress_only_internet_gateway ? local.num-availbility-zones : 0
  route_table_id         = aws_route_table.pubrt.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.GatewayEndPoint.*.id[count.index]
}

resource "aws_route" "pub-default-eg" {
  count                  = contains(keys(var.subnets), var.pub_layer) && var.egress_only_internet_gateway ? 1 : 0
  route_table_id         = join("",aws_route_table.pubrt.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = join("",aws_egress_only_internet_gateway.eg-inet-gw.*.id)
}
*/

/* Gateway Endpoint Routing Setup */

/*
resource "aws_route_table" "gweprt" {
  count  = contains(keys(var.subnets), var.pub_layer) && var.deploy_gwep && !(var.egress_only_internet_gateway) ? local.num-availbility-zones : 0
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(
    var.tags,
    tomap({ "Name" = format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-gwep")}),
    local.resource-tags["aws_route_table"]
  )
}

resource "aws_route" "gweprt-route" {
  count                  = contains(keys(var.subnets), var.pub_layer) && var.deploy_gwep && !(var.egress_only_internet_gateway) ? local.num-availbility-zones : 0
  route_table_id         = aws_route_table.gweprt.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inet-gw.0.id
}

resource "aws_route_table_association" "gweprt" {
  count          = contains(keys(var.subnets), var.pub_layer) && var.deploy_gwep && !(var.egress_only_internet_gateway) ? local.num-availbility-zones : 0
  subnet_id      = aws_subnet.gwep.*.id[count.index]
  route_table_id = aws_route_table.gweprt.*.id[count.index]
}

resource "aws_route_table" "igwrt" {
  count  = contains(keys(var.subnets), var.pub_layer) && var.deploy_gwep && !(var.egress_only_internet_gateway) ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(
    var.tags,
    tomap({ "Name" = format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-igw") }),
    local.resource-tags["aws_route_table"]
  )
}

resource "aws_route_table_association" "igwrt-association" {
  count          = contains(keys(var.subnets), var.pub_layer) && var.deploy_gwep && !(var.egress_only_internet_gateway) ? 1 : 0
  gateway_id     = aws_internet_gateway.inet-gw.0.id
  route_table_id = aws_route_table.igwrt.0.id
}

resource "aws_route" "igwrt-pub-route" {
  count  = contains(keys(var.subnets), var.pub_layer) && var.deploy_gwep && !(var.egress_only_internet_gateway) ? local.num-availbility-zones : 0
  route_table_id = aws_route_table.igwrt.0.id
  vpc_endpoint_id = aws_vpc_endpoint.GatewayEndPoint.*.id[count.index]
  destination_cidr_block = cidrsubnet(var.subnets[var.pub_layer],ceil(log(length(var.zones[var.region]),2)),local.azs-list[count.index])
}
*/