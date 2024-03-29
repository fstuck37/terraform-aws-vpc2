resource "aws_vpc_dhcp_options" "dhcp-opt" {
  domain_name         = var.domain_name
  domain_name_servers = var.domain_name_servers
  ntp_servers         = var.ntp_servers
  tags = merge(
    var.tags,
    tomap({ "Name" = format("%s", "${var.name-vars["account"]}-${replace(var.region, "-", "")}-${var.name-vars["name"]}-dhcp-options") }),
    local.resource-tags["aws_vpc_dhcp_options"]
  )
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.main_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp-opt.id
}