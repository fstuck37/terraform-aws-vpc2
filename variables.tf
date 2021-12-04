variable "region" {
  type        = string
  description = "Required : The AWS Region to deploy the VPC to. Defaults to us-"
  default     = "us-east-1"
}

variable "vpc-cidrs" {
  description = "Required : List of CIDRs to apply to the VPC."
  type        = list(string)
  default     = ["10.0.0.0/21"]

  validation {
    condition = (
      length(var.vpc-cidrs)>=1
    )
    error_message = "The instance_tenancy is not valid."
  }
}

variable "enable_dns_hostnames" {
  description = "Optional : A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  type        = bool
  default     = true
}

variable "enable_route53_reverse_zones" {
  description = "Optional : A boolean flag to enable/disable creation of reverse DNS zones for all /24 networks in the VPC. Anything smaller than a /24 will be ignored. Default is false"
  type        = bool
  default     = false
}

variable "enable_route53_shared_resolver_rules" {
  description = "Optional : Enable Route53 resolver rules. Defaults to false"
  default     = false
}

variable "enable_route53_outbound_endpoint" {
  type = bool
  description = "Optional : A boolean flag to enable/disable Route53 Outbound Endpoint. Defaults false."
  default = false
}

variable "enable_route53_inbound_endpoint" {
  type = bool
  description = "Optional : A boolean flag to enable/disable Route53 Resolver Endpoint. Defaults false."
  default = false
}

variable "route53_resolver_endpoint_cidr_blocks" {
  type = list(string)
  description = "Optional : A list of the source CIDR blocks to allow to commuicate with the Route53 Resolver Endpoint. Defaults 0.0.0.0/0."
  default = ["0.0.0.0/0"]
}

variable "route53_resolver_endpoint_subnet" {
  type = string
  description = "Optional : The subnet to install Route53 Resolver Endpoint , the default is mgt but must exist as a key in the variable subnets."
  default = "mgt"
}

variable "route53_resolver_rules" {
  /* type = list{object(
    domain_name = string
    rule_type   = string  # FORWARD, SYSTEM and RECURSIVE
    name        = string
    target_ip   = list(objects(
      ip        = string
      port      = number
    ))
    tags        = map(string)
  )) */
  description = "Optional : List of Route53 Resolver Rules"
  default = []
}


variable "default_route53_resolver_rules_target_ip" {
  description = "Do not use: This defines the default values for each map entry in route53_resolver_rules target_ip. Do not override this."
  default = { 
      port      = null
  }
}


variable "default_route53_resolver_rules" {
  description = "Do not use: This defines the default values for each map entry in route53_resolver_rules. Do not override this."
  default = { 
    # domain_name = null - Required 
    rule_type   = "FORWARD"
    name        = null
    target_ip   = []
    tags        = {}
  }
}

variable "enable_dns_support" {
  description = "Optional : A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "Optional : A tenancy option for instances launched into the VPC. Default is default, which makes your instances shared on the host. Using either of the other options (dedicated or host) costs at least $2/hr."
  type        = string
  default     = "default"

  validation {
    condition = (
      contains(["default", "dedicated", "host",], var.instance_tenancy)
    )
    error_message = "The instance_tenancy is not valid."
  }
}

variable "tags" {
  type        = map(string)
  description = "Optional : A map of tags to assign to the resource."
  default     = {}
}

variable "vpc-name" {
  description = "Optional : Override the calculated VPC name"
  type        = string
  default     = "null"
}

variable "name-vars" {
  description = "Required : Map with two keys account and name. Names of elements are created based on these values."
  type        = map(string)

  validation {
    condition = (
      contains(keys(var.name-vars), "account") && 
      contains(keys(var.name-vars), "name")
    )
    error_message = "The input name-vars must contain two elements account and name."
  }
}

variable "resource-tags" {
  description = "Optional : A map of maps of tags to assign to specifc resources. This can be used to override globally specified or calculated tags such as the name. The key must be one of the following: aws_vpc, aws_vpn_gateway, aws_subnet, aws_network_acl, aws_internet_gateway, aws_cloudwatch_log_group, aws_vpc_dhcp_options, aws_route_table, aws_route53_resolver_endpoint, aws_lb."
  type        = map(map(string))
  default     = { }
}

variable "subnet-tags" {
  type = map(map(string))
  description = "Optional : A map of maps of tags to assign to specifc subnet resource.  The key but be the same as the key in variable subnets."
  default = { }
}

variable "domain_name" {
  description = "Optional : the suffix domain name to use by default when resolving non Fully Qualified Domain Names. In other words, this is what ends up being the search value in the /etc/resolv.conf file."
  type        = string
  default     = "ec2.internal"
}


variable "domain_name_servers" {
  description = "Optional : List of name servers to configure in /etc/resolv.conf. The default is the AWS nameservers AmazonProvidedDNS."
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "ntp_servers" {
  description = "Optional : List of NTP servers to configure. The default is an emppty list."
  type        = list(string)
  default     = []
}

variable "dx_gateway_id" {
  description = "Optional : specify the Direct Connect Gateway ID to associate the VGW with."
  type        = string
  default     = "null"
}

variable "transit_gateway_id" {
  description = "Optional : specify the Transit Gateway ID within the same account to associate the VPC with."
  type = string
  default     = "null"
}

variable "transit_gateway_routes" {
  description = "Optional : specify the list of CIDR blocks to route to the Transit Gateway."
  type = list(string)
  default     = []
}

variable "txgw_layer" {
  type        = string
  description = "Optional : Specifies the name of the layer to connect the TXGW to. Defaults to mgt."
  default     = "mgt"
}

variable "appliance_mode_support" {
  description = "(Optional) Whether Appliance Mode support is enabled. If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow. Valid values: disable, enable. Default value: disable."
  default     = "disable"
}

variable "pub_layer" {
  type        = string
  description = "Optional : Specifies the name of the public layer. Defaults to pub."
  default     = "pub"
}

variable "reserve_azs" {
   description = "Optional : The number of subnets to compute the IP allocations for. If greater than the existing numnber of availbility zones in the zones list it will reserve space for additional subnets if less then it will only allocate for the existing AZs. The default is 0."
   type        = number
   default     = 0
}

variable "subnets" {
  description = "Optional : Keys are used for subnet names and values are the subnets for the various layers. These will be divided by the number of AZs based on ceil(log(length(var.zones[var.region]),2)). 'pub' is the only special name used for the public subnet and must be specified first."
  type = map(string)
  default = {
    pub = "10.0.0.0/24"
    web = "10.0.1.0/24"
    app = "10.0.2.0/24"
    db  = "10.0.3.0/24"
    mgt = "10.0.4.0/24"
  }
}

variable "subnet-order" {
  description = "Required : Order in which subnets are created. Changes can cause recreation issues when subnets are added when something precedes other subnets. Must include all key names in subnets"
  type = list(string)
}

variable "block_tcp_ports" {
  description = "Optional : Ports to block both inbound and outbound in the Public Subnet NACL."
  type = list(string)
  default = ["20-21", "22", "23", "53", "137-139", "445", "1433", "1521", "3306", "3389", "5439", "5432"]
}

variable "block_udp_ports" {
  description = "Optional : Ports to block both inbound and outbound in the Public Subnet NACL."
  type = list(string)
  default = ["53"]
}

variable "network_acl_rules" {
  type = map(object({
    rule_number         = number
    egress              = bool
    protocol            = string
    rule_action         = string
    cidr_block          = string
    from_port           = number
    to_port             = number
    icmp_type           = number
  }))
  description = "Optional: Map of Map of ingress or egress rules to add to Public Subnet's NACL."
  default = {}
}

variable "deploy_natgateways" {
  description = "Optional : Set to true to deploy NAT gateways if pub subnet is created. Defaults to false."
  type        = bool
  default     = false
}

variable "enable_pub_route_propagation" {
  description = "Optional : A boolean flag that indicates that the routes should be propagated to the pub routing table. Defaults to False."
  type        = bool
  default     = false
}

variable "enable_flowlog" {
  description = "Optional : A boolean flag to enable/disable VPC flowlogs."
  type        = bool
  default     = false
}

variable "aws_lambda_function_name" {
  description = "Optional : Lambda function name to call when sending to logs to an external SEIM."
  type        = string
  default     = "null"
}

variable "flow_log_filter" {
  description = "Optional : CloudWatch subscription filter to match flow logs."
  default     = ""
}

variable "flow_log_format" {
  description = "Optional : VPC flow log format."
  type        = string
  default = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path}"
}

variable "cloudwatch_retention_in_days" {
  description = "Optional : Number of days to keep logs within the cloudwatch log_group. The default is 7 days."
  type        = number
  default     = 7
}

variable "amazonaws-com" {
  description = "Optional : Ability to change principal for flowlogs from amazonaws.com to amazonaws.com.cn."
  default = "amazonaws.com"
}

variable "acctnum" {
  description = "Required : AWS Account Number"
  default = ""
}

variable "enable-s3-endpoint" {
  description = "Optional : Enable the S3 Endpoint"
  default     = false
}

variable "enable-dynamodb-endpoint" {
  description = "Optional : Enable the DynamoDB Endpoint"
  default     = false
}

variable "private_endpoints" {
  description = "List of Maps for private AWS Endpoints Keys: name[Name of Resource IE: s3-endpoint], service[The Service IE: com.amazonaws.<REGION>.execute-api, <REGION> will be replaced with VPC Region], List of security_group IDs, List of subnet layers to deploy interfaces to."
  type = list(object({
    name                = string
    subnets             = list(string)
    service             = string
    security_groups     = list(string)
    private_dns_enabled = bool
  }))
  default = []
}

variable "enable_vpn_gateway" {
  description = "Optional : Create a new VPN Gateway. Defaults to true."
  default     = true
}

variable "peer_requester" {
  description = "Optional : Map of maps of Peer Link requestors. The key is the name and the elements of the individual maps are peer_owner_id, peer_vpc_id, peer_cidr_blocks (list), and allow_remote_vpc_dns_resolution."
  type = map(object({
    peer_owner_id                   = string
    peer_vpc_id                     = string
    peer_cidr_blocks                = list(string)
    allow_remote_vpc_dns_resolution = bool
  }))
  default = {}
}

variable "peer_accepter" {
  description = "Optional : Map of maps of Peer Link accepters. The key is the name and the elements of the individual maps are vpc_peering_connection_id, peer_cidr_blocks (list), allow_remote_vpc_dns_resolution."
  type = map(object({
    vpc_peering_connection_id = string
    peer_cidr_blocks          = list(string)
    allow_remote_vpc_dns_resolution = bool
  }))
  default = {}
}

variable "vpn_connections" {
  description = "Optional : A map of a map with the settings for each VPN.  The key will be the name of the VPN"
  /*
    type = map(object({
      peer_ip_address                      = string		# Required so not in default_vpn_connections
      device_name                          = string
      bgp_asn                              = number
      
      static_routes_only                   = bool
      local_ipv4_network_cidr              = string
      remote_ipv4_network_cidr             = string
      tunnel_inside_ip_version             = string		# ipv4* | ipv6

      tunnel1_inside_cidr                  = string
      tunnel1_preshared_key                = string
      tunnel1_dpd_timeout_action           = string		# clear* | none | restart
      tunnel1_dpd_timeout_seconds          = number		# >30 =30*
      tunnel1_ike_versions                 = list(string)	# ikev1 | ikev2
      tunnel1_phase1_dh_group_numbers      = list(number)	# 2 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24
      tunnel1_phase1_encryption_algorithms = list(string)	# AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16
      tunnel1_phase1_integrity_algorithms  = list(string)	# SHA1 | SHA2-256 | SHA2-384 | SHA2-512
      tunnel1_phase1_lifetime_seconds      = number		# 900 and 28800*
      tunnel1_phase2_dh_group_numbers      = list(number)	# 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24
      tunnel1_phase2_encryption_algorithms = list(string)	# AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16
      tunnel1_phase2_integrity_algorithms  = list(string)	# SHA1 | SHA2-256 | SHA2-384 | SHA2-512
      tunnel1_phase2_lifetime_seconds      = number		# 900 and 3600*
      tunnel1_rekey_fuzz_percentage        = number		# between 0 and 100*
      tunnel1_rekey_margin_time_seconds    = number		# 60 and half of tunnel1_phase2_lifetime_seconds 540*
      tunnel1_replay_window_size           = number		# between 64 and 2048.
      tunnel1_startup_action               = string		# add* | start

      tunnel2_inside_cidr                  = string
      tunnel2_preshared_key                = string
      tunnel2_dpd_timeout_action           = string
      tunnel2_dpd_timeout_seconds          = string
      tunnel2_ike_versions                 = string
      tunnel2_phase1_dh_group_numbers      = string
      tunnel2_phase1_encryption_algorithms = string 
      tunnel2_phase1_integrity_algorithms  = string
      tunnel2_phase1_lifetime_seconds      = string
      tunnel2_phase2_dh_group_numbers      = string
      tunnel2_phase2_encryption_algorithms = string 
      tunnel2_phase2_integrity_algorithms  = string
      tunnel2_phase2_lifetime_seconds      = string
      tunnel2_rekey_fuzz_percentage        = string
      tunnel2_rekey_margin_time_seconds    = string
      tunnel2_replay_window_size           = string
      tunnel2_startup_action               = string

      tags                    = map(string)

      destination_cidr_blocks = list(string)

    }))
  */
  default = { }
}

variable "default_vpn_connections" {
  description = "Do not use: This defines the default values for each map entry in vpn_connections. Do not override this."
  default = { 
      # aws_customer_gateway
      device_name                          = null
      bgp_asn                              = 6500
      
      # aws_vpn_connection
      static_routes_only                   = true
      local_ipv4_network_cidr              = null
      remote_ipv4_network_cidr             = null
      tunnel_inside_ip_version             = "ipv4"

      tunnel1_inside_cidr                  = null
      tunnel1_preshared_key                = null
      tunnel1_dpd_timeout_action           = "clear"
      tunnel1_dpd_timeout_seconds          = 30
      tunnel1_ike_versions                 = ["ikev1", "ikev2"]
      tunnel1_phase1_dh_group_numbers      = [2,14,15,16,17,18,19,20,21,22,23,24]
      tunnel1_phase1_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
      tunnel1_phase1_integrity_algorithms  = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
      tunnel1_phase1_lifetime_seconds      = 28800
      tunnel1_phase2_dh_group_numbers      = [2,5,14,15,16,17,18,19,20,21,22,23,24]
      tunnel1_phase2_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
      tunnel1_phase2_integrity_algorithms  = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
      tunnel1_phase2_lifetime_seconds      = 3600
      tunnel1_rekey_fuzz_percentage        = 100
      tunnel1_rekey_margin_time_seconds    = 540
      tunnel1_replay_window_size           = 1024
      tunnel1_startup_action               = "add"

      tunnel2_inside_cidr                  = null
      tunnel2_preshared_key                = null
      tunnel2_dpd_timeout_action           = "clear"
      tunnel2_dpd_timeout_seconds          = 30
      tunnel2_ike_versions                 = ["ikev1", "ikev2"]
      tunnel2_phase1_dh_group_numbers      = [2,14,15,16,17,18,19,20,21,22,23,24]
      tunnel2_phase1_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
      tunnel2_phase1_integrity_algorithms  = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
      tunnel2_phase1_lifetime_seconds      = 28800
      tunnel2_phase2_dh_group_numbers      = [2,5,14,15,16,17,18,19,20,21,22,23,24]
      tunnel2_phase2_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]
      tunnel2_phase2_integrity_algorithms  = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]
      tunnel2_phase2_lifetime_seconds      = 3600
      tunnel2_rekey_fuzz_percentage        = 100
      tunnel2_rekey_margin_time_seconds    = 540
      tunnel2_replay_window_size           = 1024
      tunnel2_startup_action               = "add"

      tags                                 = {}

      # Static Routes
      destination_cidr_blocks              = []
  }
}
































/* --------------------------------------------------------------------------- */


/*


variable "subnets_ignore_changes" {
  default = ["tags"]
}




variable "fixed-subnets" {
  type = map(list(string))
  description = "Optional : Keys must match subnet-order and values are the list of subnets for each AZ. The number of subnets specified in each list needs to match the number of AZs. 'pub' is the only special name used."
  default = { }
}

variable "fixed-name" {
  type = map(list(string))
  description = "Optional : Keys must match subnet-order and values are the name of subnets for each AZ. The number of subnets specified in each list needs to match the number of AZs. 'pub' is the only special name used."
  default = { }
}

variable "dx_bgp_default_route" {
  description = "Optional : A boolean flag that indicates that the default gateway will be advertised via bgp over Direct Connect and causes the script to not deploy NAT Gateways."
  default     = false
}

variable "egress_only_internet_gateway" {
  description = "Optional : Deploy egress_only_internet_gateway instead of aws_internet_gateway"
  default     = false
}

variable "deploy_gwep" {
  description = "Optional : Setup Gateway Load Balancer Endpoint components"
  default = false
}

variable "gwep_subnet" {
  description = "Optional : CIDR Blocked used for the Gateway Endpoints"
  default = ""
}

variable "gwep_service_name" {
  description = "Optional : Service Name for Gateway Endpoint"
  default = ""
}

*/