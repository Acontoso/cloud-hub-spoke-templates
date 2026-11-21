variable "vpc_cidr" {
  description = "Canonical IPv4 CIDR for the VPC, with an AWS-supported /16 through /28 prefix."
  type        = string
  nullable    = false
}

variable "name_prefix" {
  description = "Nonempty prefix for network resource names."
  type        = string
  default     = "inspection"
  nullable    = false
}

variable "public_subnets" {
  description = "Canonical IPv4 public/NAT subnet CIDRs, one per AZ in availability_zones order."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.public_subnets) == var.az_count
    error_message = "Provide exactly one public subnet CIDR per AZ."
  }
}

variable "cc_subnets" {
  description = "Canonical IPv4 Cloud Connector subnet CIDRs, one per AZ in availability_zones order."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.cc_subnets) == var.az_count
    error_message = "Provide exactly one Cloud Connector subnet CIDR per AZ."
  }
}

variable "workload_subnets" {
  description = "Canonical IPv4 workload subnet CIDRs, one per AZ in availability_zones order."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.workload_subnets) == var.az_count
    error_message = "Provide exactly one workload subnet CIDR per AZ."
  }
}

variable "tgw_subnets" {
  description = "Canonical IPv4 TGW attachment subnet CIDRs, one per AZ in availability_zones order."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.tgw_subnets) == var.az_count
    error_message = "Provide exactly one TGW subnet CIDR per AZ."
  }
}

variable "az_count" {
  description = "Number of AZs and subnets in each subnet tier; must be an integer from 1 through 6."
  type        = number
  default     = 3
  nullable    = false
  validation {
    condition     = var.az_count >= 1 && var.az_count <= 6 && floor(var.az_count) == var.az_count
    error_message = "az_count must be an integer from 1 through 6."
  }
}

variable "availability_zones" {
  description = "Ordered AZ names. Empty discovers available AZs; otherwise supply exactly az_count distinct names."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = length(var.availability_zones) == 0 || (length(var.availability_zones) == var.az_count && length(distinct(var.availability_zones)) == var.az_count)
    error_message = "Supply exactly az_count distinct AZ names, or leave empty for discovery."
  }
}

variable "static_routes_tgw" {
  description = "Unique canonical IPv4 routes installed in CC, workload and TGW route tables toward transit_gateway_id. Default routes are not allowed."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = length(distinct(var.static_routes_tgw)) == length(var.static_routes_tgw) && !contains(var.static_routes_tgw, "0.0.0.0/0")
    error_message = "Static TGW routes must be unique and must not include the 0.0.0.0/0 default route."
  }
}

variable "transit_gateway_id" {
  description = "Existing TGW ID for static routes. Required when static_routes_tgw is nonempty; attachment is managed by the caller."
  type        = string
  default     = null

  validation {
    condition     = var.transit_gateway_id == null || can(regex("^tgw-[0-9a-f]+$", var.transit_gateway_id))
    error_message = "transit_gateway_id must be a TGW resource ID."
  }
}

variable "flow_logs_enabled" {
  description = "Enable ALL VPC flow logs delivered to a dedicated CloudWatch Logs group. Ingestion and storage charges apply."
  type        = bool
  default     = true
  nullable    = false
}

variable "flow_log_retention_days" {
  description = "CloudWatch flow log retention in days. Zero retains indefinitely and can increase storage costs."
  type        = number
  default     = 30
  nullable    = false
}

variable "tags" {
  description = "Tags applied to module resources that support tags."
  type        = map(string)
  default     = {}
  nullable    = false
}
