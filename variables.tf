variable "region" {
  description = "Optional : The AWS Region to deploy the VPC to. Defaults to us-east-1"
  type        = string
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

variable "override_default_security_group" {
  description = "Optional : Takes over the rule set of the VPC's default Security Group and removes all rules. Defaults false."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Optional : A boolean flag to enable/disable DNS hostnames in the VPC. Defaults true."
  type        = bool
  default     = true
}

variable "enable_route53_reverse_zones" {
  description = "Optional : A boolean flag to enable/disable creation of reverse DNS zones for all /24 networks in the VPC. Anything smaller than a /24 will be ignored. Default is false"
  type        = bool
  default     = false
}

variable "enable_route53_shared_resolver_rules" {
  description = "Optional : Enable Route53 resolver rule associations. Defaults to false"
  type        = bool
  default     = false
}

variable "exclude_resolver_rule_ids" {
  description = "Optional : A list of resolve rule IDs to exclude from the resolve rule associations."
  type        = list(string)
  default     = []
}

variable "route53_resolver_endpoint_cidr_blocks" {
  description = "Optional : A list of the source CIDR blocks to allow to commuicate with the Route53 Resolver Endpoint. Defaults 0.0.0.0/0."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "route53_resolver_endpoint_subnet" {
  description = "Optional : The subnet to install Route53 Resolver Endpoint , the default is mgt but must exist as a key in the variable subnets."
  type        = string
  default     = "mgt"
}

variable "enable_route53_inbound_endpoint" {
  description = "Optional : A boolean flag to enable/disable Route53 Resolver Endpoint. Defaults false."
  type        = bool
  default     = false
}

variable "enable_route53_outbound_endpoint" {
  description = "Optional : A boolean flag to enable/disable Route53 Outbound Endpoint. Defaults false."
  type        = bool
  default     = false
}

variable "route53_resolver_rules" {
  description = "Optional : List of Route53 Resolver Rules"
/*type        = list{object(
    domain_name = string
    rule_type   = string  # FORWARD, SYSTEM and RECURSIVE
    name        = string
    target_ip   = map(list(objects(
      ip        = string
      port      = number
    )))
    tags        = map(string)
  )) */
  default     = []
}

variable "default_route53_resolver_rules" {
  description = "Do not use : This defines the default values for each map entry in route53_resolver_rules. Do not override this."
 /*type       = map(object({
    rule_type = string
    name      = string
    target_ip = list(string)
    tags      = map(string)
  })) */
  default     = { 
#   domain_name = null - Required not set
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
  description = "Optional : A map of tags to assign to the resource."
  type        = map(string)
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
  type        = string
  default     = "null"
}

variable "transit_gateway_routes" {
  description = "Optional : specify the list of CIDR blocks to route to the Transit Gateway."
  type        = list(string)
  default     = []
}

variable "txgw_layer" {
  description = "Optional : Specifies the name of the layer to connect the TXGW to. Defaults to mgt."
  type        = string
  default     = "mgt"
}

variable "appliance_mode_support" {
  description = "(Optional) : Whether Appliance Mode support is enabled. If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow. Valid values: disable, enable. Default value: disable."
  type        = string
  default     = "disable"
}

variable "pub_layer" {
  description = "Optional : Specifies the name of the public layer. Defaults to pub."
  type        = string
  default     = "pub"
}

variable "reserve_azs" {
  description = "Optional : The number of subnets to compute the IP allocations for. If greater than the existing numnber of availbility zones in the zones list it will reserve space for additional subnets if less then it will only allocate for the existing AZs. The default is 0."
  type        = number
  default     = 0
}

variable "subnets" {
  description = "Optional : Keys are used for subnet names and values are the subnets for the various layers. These will be divided by the number of AZs based on ceil(log(length(var.zones[var.region]),2)). 'pub' is the only special name used for the public subnet and must be specified first."
  type        = map(string)
  default     = {
    pub = "10.0.0.0/24"
    web = "10.0.1.0/24"
    app = "10.0.2.0/24"
    db  = "10.0.3.0/24"
    mgt = "10.0.4.0/24"
  }
}

variable "fixed-subnets" {
  description = "Optional : Keys must match keys in subnets and values are the list of subnets for each AZ. The number of subnets specified in each list needs to match the number of AZs. 'pub' is the only special name used."
  type        = map(list(string))
  default     = { }
}

variable "fixed-name" {
  description = "Optional : Keys must match keys in subnets and values are the name of subnets for each AZ. The number of subnets specified in each list needs to match the number of AZs. 'pub' is the only special name used."
  type        = map(list(string))
  default     = { }
}

variable "subnet-tags" {
  description = "Optional : A map of maps of tags to assign to specifc subnet resource.  The key but be the same as the key in variable subnets."
  type        = map(map(string))
  default     = { }
}

variable "block_tcp_ports" {
  description = "Optional : Ports to block both inbound and outbound in the Public Subnet NACL."
  type        = list(string)
  default     = ["20-21", "22", "23", "53", "137-139", "445", "1433", "1521", "3306", "3389", "5439", "5432"]
}

variable "block_udp_ports" {
  description = "Optional : Ports to block both inbound and outbound in the Public Subnet NACL."
  type        = list(string)
  default     = ["53"]
}

variable "network_acl_rules" {
  description = "Optional : Map of Map of ingress or egress rules to add to Public Subnet's NACL."
  type        = map(object({
    rule_number = number
    egress      = bool
    protocol    = string
    rule_action = string
    cidr_block  = string
    from_port   = number
    to_port     = number
    icmp_type   = number
  }))
  default     = {}
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

variable "flow_log_destination_type" {
  description = "Optional : Type of flow log destination. Can be s3 or cloud-watch-logs. Defaults to S3."
  type        = string
  default     = "s3"
}

variable "flow_log_traffic_type" {
  description = "Optional : The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL."
  type        = string
  default     = "ALL"
}

variable "flow_log_max_aggregation_interval" {
  description = "Optional : The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds. Defaults to 600."
  type        = number
  default     = 600
}

variable "cloudwatch_retention_in_days" {
  description = "Optional : Number of days to keep logs within the cloudwatch log_group. The default is 7 days."
  type        = number
  default     = 7
}

variable "flow_log_format" {
  description = "Optional : VPC flow log format."
  type        = string
  default     = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path}"
}

variable "flow_log_filter" {
  description = "Optional : CloudWatch subscription filter to match flow logs."
  type        = string
  default     = ""
}

variable "flow_log_destination_arn" {
  description = "Optional : Required if enable_flowlog = true and destination type s3. The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. When create_flow_log_cloudwatch_log_group is set to false this argument must be provided."
  type        = string
  default     = ""
}

variable "aws_lambda_function_name" {
  description = "Optional : Lambda function name to call when sending logs to an external SEIM from CloudWatch. This is ignored if sending logs to S3."
  type        = string
  default     = "null"
}










variable "amazonaws-com" {
  description = "Optional : Ability to change principal for flowlogs from amazonaws.com to amazonaws.com.cn."
  type        = string
  default     = "amazonaws.com"
}

variable "enable-s3-endpoint" {
  description = "Optional : Enable the S3 Endpoint"
  type        = bool
  default     = false
}

variable "enable-dynamodb-endpoint" {
  description = "Optional : Enable the DynamoDB Endpoint"
  type        = bool
  default     = false
}

variable "private_endpoints" {
  description = "Optional : List of Maps for private AWS Endpoints Keys: name[Name of Resource IE: s3-endpoint], service[The Service IE: com.amazonaws.<REGION>.execute-api, <REGION> will be replaced with VPC Region], List of security_group IDs, List of subnet layers or Subnet IDs to deploy interfaces to. When layer is used all subnets in each layer will be used. This can cause errors if the endpoint is not available in the AZ. Use subnet IDs if this happens."
  type        = list(object({
    name                = string
    subnets             = list(string)
    service             = string
    security_groups     = list(string)
    private_dns_enabled = bool
  }))
  default     = []
}

variable "enable_vpn_gateway" {
  description = "Optional : Create a new VPN Gateway. Defaults to true."
  type        = bool
  default     = true
}

variable "peer_requester" {
  description = "Optional : Map of maps of Peer Link requestors. The key is the name and the elements of the individual maps are peer_owner_id, peer_vpc_id, peer_cidr_blocks (list), and allow_remote_vpc_dns_resolution."
  type        = map(object({
    peer_owner_id                   = string
    peer_vpc_id                     = string
    peer_cidr_blocks                = list(string)
    allow_remote_vpc_dns_resolution = bool
  }))
  default     = {}
}

variable "peer_accepter" {
  description = "Optional : Map of maps of Peer Link accepters. The key is the name and the elements of the individual maps are vpc_peering_connection_id, peer_cidr_blocks (list), allow_remote_vpc_dns_resolution."
  type        = map(object({
    vpc_peering_connection_id       = string
    peer_cidr_blocks                = list(string)
    allow_remote_vpc_dns_resolution = bool
  }))
  default     = {}
}

variable "vpn_connections" {
  description = "Optional : A map of a map with the settings for each VPN.  The key will be the name of the VPN"
/*type        = map(object({
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

    })) */
  default     = { }
}

variable "default_vpn_connections" {
  description = "Optional : This defines the default values for each map entry in vpn_connections. Only overide this if you want to change the defaults for all VPNs."
/*type        = map(object(...)) */
  default     = { 
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

variable "dx_bgp_default_route" {
  description = "Optional : A boolean flag that indicates that the default gateway will be advertised via bgp over Direct Connect and causes the script to not default routes to the NAT Gateways."
  type        = bool
  default     = false
}

variable "zones" {
  description = "Optional : AWS Regions and Availability Zones"
  type        = map(list(string))
  default     = {
    us-east-1 = [
      "us-east-1a",
      "us-east-1b",
      "us-east-1c"
    ]
    us-east-2 = [
      "us-east-2a",
      "us-east-2b",
      "us-east-2c"
    ]
    us-west-1 = [
      "us-west-1a",
      "us-west-1b",
      "us-west-1c"
    ]
    us-west-2 = [
      "us-west-2a",
      "us-west-2b",
      "us-west-2c"
    ]
    ca-central-1 = [
      "ca-central-1a",
      "ca-central-1b",
      "ca-central-1c"
    ]
    eu-west-1 = [
      "eu-west-1a",
      "eu-west-1b",
      "eu-west-1c"
    ]
    eu-west-2 = [
      "eu-west-2a",
      "eu-west-2b",
      "eu-west-2c"
    ]
    eu-central-1 = [
      "eu-central-1a",
      "eu-central-1b",
      "eu-central-1c"
    ]
    ap-northeast-1 = [
      "ap-northeast-1a",
      "ap-northeast-1b",
      "ap-northeast-1c"
    ]
    ap-northeast-2 = [
      "ap-northeast-2a",
      "ap-northeast-2b",
      "ap-northeast-2c"
    ]
    ap-southeast-1 = [
      "ap-southeast-1a",
      "ap-southeast-1b",
      "ap-southeast-1c"
    ]
    ap-southeast-2 = [
      "ap-southeast-2a",
      "ap-southeast-2b",
      "ap-southeast-2c"
    ]
    ap-south-1 = [
      "ap-south-1a",
      "ap-south-1b",
      "ap-south-1c"
    ]
    sa-east-1 = [
      "sa-east-1a",
      "sa-east-1b",
      "sa-east-1c"
    ]    
    us-gov-west-1 = [
      "us-gov-west-1a",
      "us-gov-west-1c",
      "us-gov-west-1b"
    ]
    us-gov-east-1 = [
      "us-gov-east-1a",
      "us-gov-east-1c",
      "us-gov-east-1b"
    ]
    cn-north-1 = [
      "cn-north-1a",
      "cn-north-1b"
    ]
    cn-northwest-1 = [
      "cn-northwest-1a",
      "cn-northwest-1b",
      "cn-northwest-1c",
    ]
  }
}
