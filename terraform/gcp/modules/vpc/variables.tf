variable "name_prefix" {
  type        = string
  description = "Lowercase prefix applied to all VPC, subnet, router, NAT, and firewall resource names. Must satisfy Google Cloud resource-naming rules (lowercase letters, numbers, hyphens; start with a letter; at most 40 characters)."
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 40
    error_message = "name_prefix must be 1-40 characters and valid for Google Cloud resource names."
  }
}

variable "project" {
  type        = string
  description = "Google Cloud project ID where the VPC resources are created."
  validation {
    condition     = length(trimspace(var.project)) > 0
    error_message = "project must be a non-empty Google Cloud project ID."
  }
}

variable "region" {
  type        = string
  description = "Google Cloud region for the subnets, routers, and NAT gateways."
  default     = "australia-southeast1"
  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "region must be a non-empty Google Cloud region such as australia-southeast1."
  }
}

variable "subnet_cc_service" {
  type        = string
  description = "IPv4 CIDR range for the Cloud Connector service/load balancer subnet in the service VPC."
  validation {
    condition     = can(cidrhost(var.subnet_cc_service, 0))
    error_message = "subnet_cc_service must be a valid CIDR block, for example 10.10.0.0/24."
  }
}

variable "subnet_mgmt" {
  type        = string
  description = "IPv4 CIDR range for the Cloud Connector management subnet in the management VPC."
  validation {
    condition     = can(cidrhost(var.subnet_mgmt, 0))
    error_message = "subnet_mgmt must be a valid CIDR block, for example 10.10.1.0/24."
  }
}

variable "routing_mode" {
  type        = string
  description = "Network-wide routing mode for both VPCs. Possible values are REGIONAL and GLOBAL."
  default     = "REGIONAL"
  validation {
    condition     = var.routing_mode == "REGIONAL" || var.routing_mode == "GLOBAL"
    error_message = "routing_mode must be either REGIONAL or GLOBAL."
  }
}
