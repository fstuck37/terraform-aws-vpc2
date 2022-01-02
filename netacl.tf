resource "aws_network_acl" "net_acl" {
  for_each = { for i in [var.region] : i => i
  if contains(keys(var.subnets), var.pub_layer) }
  vpc_id = aws_vpc.main_vpc.id
  subnet_ids = [for i in local.subnet_data : aws_subnet.subnets[i.name].id
  if i.layer == var.pub_layer]
  tags = merge(
    var.tags,
    tomap({ "Name" = format("%s", "${var.name-vars["account"]}-${replace(var.region, "-", "")}-${var.name-vars["name"]}-nacl") }),
    local.resource-tags["aws_network_acl"]
  )
}

resource "aws_network_acl_rule" "nacle" {
  for_each = { for k, v in local.nacl_rules : k => v
  if contains(keys(var.subnets), var.pub_layer) }
  network_acl_id = aws_network_acl.net_acl[var.region].id
  rule_number    = each.value.rule_number
  egress         = each.value.egress
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port
}

/* Allow everything else ingress  */
resource "aws_network_acl_rule" "acle-permit-ingress" {
  for_each = { for i in [var.region] : i => i
  if contains(keys(var.subnets), var.pub_layer) }
  network_acl_id = aws_network_acl.net_acl[var.region].id
  rule_number    = "32750"
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

/* Allow everything else egress */
resource "aws_network_acl_rule" "acle-permit-egress" {
  for_each = { for i in [var.region] : i => i
  if contains(keys(var.subnets), var.pub_layer) }
  network_acl_id = aws_network_acl.net_acl[var.region].id
  rule_number    = "32750"
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}