/* Route 53 Reverse DNS Zones */
resource "aws_route53_zone" "reverse_zones" {
  for_each = { for cidr in local.route53-reverse-zones : "${replace(cidr, "/", "-")}" => cidr 
               if var.enable_route53_reverse_zones }
    name = "${element(split(".",element(split("/",each.value ),0)),2)}.${element(split(".",element(split("/",each.value ),0)),1)}.${element(split(".",element(split("/",each.value ),0)),0)}.in-addr.arpa"
    vpc {
      vpc_id = aws_vpc.main_vpc.id
    }
}


/* Route 53 Resolver Rule Associations */
resource "aws_route53_resolver_rule_association" "r53_resolver_rule_association"{
  for_each = { for key, value in toset( concat(flatten(data.aws_route53_resolver_rules.shared_resolver_rule_with_me.*.resolver_rule_ids),flatten(data.aws_route53_resolver_rules.shared_resolver_rule_by_me.*.resolver_rule_ids))) : key => value
               if var.enable_shared_resolver_rules }
    resolver_rule_id = each.value
    vpc_id           = aws_vpc.main_vpc.id
}




/* Route 53 Outbound Resolver Rules and Endpoint */
resource "aws_route53_resolver_rule" "resolver_rule" {
  for_each = {for rule in var.route53_resolver_rules : rule.domain_name => rule
              if var.enable_route53_outbound_endpoint }
    domain_name          = merge(var.default_route53_resolver_rules, each.value).domain_name
    rule_type            = merge(var.default_route53_resolver_rules, each.value).rule_type
    name                 = merge(var.default_route53_resolver_rules, each.value).name
    resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_endpoint[var.region].id

    dynamic "target_ip" {
      for_each = { for v in merge(var.default_route53_resolver_rules, each.value).target_ip : v.ip => v}
        content {
          ip = target_ip.value.ip
          port = target_ip.value.port
        }
    }

    tags = merge(
      var.tags,
      merge(var.default_route53_resolver_rules, each.value).tags
    )
}

resource "aws_route53_resolver_rule_association" "r53_outbound_rule_association"{
  for_each = { for key, value in aws_route53_resolver_rule.resolver_rule : key => value
               if var.enable_route53_outbound_endpoint }
    resolver_rule_id = each.value.id
    vpc_id           = aws_vpc.main_vpc.id
}

resource "aws_route53_resolver_endpoint" "outbound_endpoint" {
  for_each = {for ep in [var.region] : ep => ep
              if var.enable_route53_outbound_endpoint }
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


/* Route 53 Resolver Inbound Endpoint */
resource "aws_route53_resolver_endpoint" "inbound_endpoint" {

  for_each = {for r in {var.region] : r => r
              if var.enable_route53_inbound_endpoint }

  name               = "r53ept-inbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}"
  direction          = "INBOUND"
  security_group_ids = aws_security_group.sg-r53ept-inbound.*.id

  dynamic "ip_address" {
    for_each = [for i in local.subnet_data : aws_subnet.subnets[i.name].id
                if i.layer == var.route53_resolver_endpoint_subnet ]
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


/* Route 53 Resolver Security Group Endpoint */
resource "aws_security_group" "sg-r53ept-inbound" {
  for_each = {for sg in {var.region] : sg => sg
              if var.enable_route53_outbound_endpoint || var.enable_route53_inbound_endpoint }
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
