resource "aws_route53_zone" "reverse_zones" {
  for_each = { for cidr in local.route53-reverse-zones : "${replace(cidr, "/", "-")}" => cidr 
               if var.enable_route53_reverse_zones }
    name = "${element(split(".",element(split("/",each.value ),0)),2)}.${element(split(".",element(split("/",each.value ),0)),1)}.${element(split(".",element(split("/",each.value ),0)),0)}.in-addr.arpa"
    vpc {
      vpc_id = aws_vpc.main_vpc.id
    }
}

data "aws_route53_resolver_rules" "shared_resolver_rule_with_me"{
  share_status = "SHARED_WITH_ME"
}

data "aws_route53_resolver_rules" "shared_resolver_rule_by_me"{
  share_status = "SHARED_BY_ME"
}


/*


resource "aws_route53_resolver_rule_association" "r53_resolver_rule_association"{
  for_each = var.enable_shared_resolver_rules ? toset(
      concat(
        flatten(
          data.aws_route53_resolver_rules.shared_resolver_rule_with_me.*.resolver_rule_ids),
        flatten(
          data.aws_route53_resolver_rules.shared_resolver_rule_by_me.*.resolver_rule_ids))) : []
  
  resolver_rule_id = each.value
  vpc_id           = aws_vpc.main_vpc.id
}

resource "aws_security_group" "sg-r53ept-inbound" {
  count       = var.route53_resolver_endpoint || var.route53_outbound_endpoint ? 1 : 0
  name        = "r53ept-inbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}"
  description = "Allows access to the Route52 Resolver Endpoiny"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "tcp"
    cidr_blocks = var.route53_resolver_endpoint_cidr_blocks
  }

  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "udp"
    cidr_blocks = var.route53_resolver_endpoint_cidr_blocks
  }
 
  egress {
    description = "Allow all outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    var.tags,
    tomap({ "Name" = format("%s", "sg-r52ept-inbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" ) }),
    local.resource-tags["aws_route53_resolver_endpoint"]
  )
}

resource "aws_route53_resolver_endpoint" "resolver_endpoint" {
  count     = var.route53_resolver_endpoint ? 1 : 0
  name      = "r53ept-inbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}"
  direction = "INBOUND"
  security_group_ids = aws_security_group.sg-r53ept-inbound.*.id

  dynamic "ip_address" {
    for_each = local.map_subnet_id_list[var.route53_resolver_endpoint_subnet]
    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge(
    var.tags,
    tomap({ "Name" = format("%s", "sg-r52ept-inbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" )}),
    local.resource-tags["aws_route53_resolver_endpoint"]
  )
}

resource "aws_route53_resolver_endpoint" "outbound_endpoint" {
  count     = var.route53_outbound_endpoint ? 1 : 0
  name      = "r53ept-outbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}"
  direction = "OUTBOUND"
  security_group_ids = aws_security_group.sg-r53ept-inbound.*.id

  dynamic "ip_address" {
    for_each = local.map_subnet_id_list[var.route53_resolver_endpoint_subnet]
    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge(
    var.tags,
    tomap({ "Name" = format("%s", "sg-r53ept-outbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" )}),
    local.resource-tags["aws_route53_resolver_endpoint"]
  )
}

resource "aws_route53_resolver_rule" "resolver_rule" {
  for_each             = var.route53_outbound_endpoint ? {for rule in var.forward_rules : rule.domain_name => rule} : {}
  domain_name          = each.value.domain_name
  name                 = replace(each.value.domain_name,".","_")
  rule_type            = each.value.rule_type
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_endpoint.0.id

  target_ip {
    ip = element(split(",", lookup(each.value.ips, var.region, each.value.ips["us-east-1"])),0)

  }
  target_ip {
    ip = element(split(",", lookup(each.value.ips, var.region, each.value.ips["us-east-1"])),1)
  }

  tags = var.tags
}

resource "aws_route53_resolver_rule_association" "r53_outbound_rule_association"{
  for_each         = var.enable_shared_resolver_rules ? aws_route53_resolver_rule.resolver_rule : {}
  resolver_rule_id = each.value.id
  vpc_id           = aws_vpc.main_vpc.id
}

*/