resource "aws_network_acl" "net_acl" {
  for_each = { for i in [format("%s","${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-nacl")] : i=>i
               if contains( keys(var.subnets), var.pub_layer) }
  vpc_id     = aws_vpc.main_vpc.id
  subnet_ids = local.pub-subnet-ids
  tags       = merge(
    var.tags,
    tomap({ "Name" = each.value}),
    local.resource-tags["aws_network_acl"]
  )
}

resource "aws_network_acl_rule" "acle-ingress-bypass" {
  for_each = local.nacl_rules
    network_acl_id = join("",aws_network_acl.net_acl.*.id)
    rule_number    = each.value.rule_number
    egress         = each.value.egress
    protocol       = each.value.protocol
    rule_action    = each.value.rule_action
    cidr_block     = each.value.cidr_block
    from_port      = each.value.from_port
    to_port        = each.value.to_port
}