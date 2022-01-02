data "aws_caller_identity" "current" {
}

data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_route53_resolver_rules" "shared_resolver_rule_with_me" {
  share_status = "SHARED_WITH_ME"
}

data "aws_route53_resolver_rules" "shared_resolver_rule_by_me" {
  share_status = "SHARED_BY_ME"
}
