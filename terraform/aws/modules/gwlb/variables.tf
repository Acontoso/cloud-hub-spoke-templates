variable "vpc_id" {
  description = "VPC ID containing GWLB subnets and the IP target group."
  type        = string
  nullable    = false
}

variable "subnet_ids" {
  description = "Distinct GWLB subnet IDs, one per selected AZ, all belonging to vpc_id."
  type        = list(string)
  nullable    = false
}

variable "health_check_interval" {
  description = "GWLB HTTP health probe interval in seconds: 10 or 30."
  type        = number
  default     = 10
  nullable    = false
  validation {
    condition     = contains([10, 30], var.health_check_interval)
    error_message = "Gateway Load Balancer health_check_interval must be 10 or 30 seconds."
  }
}

variable "http_probe_port" {
  description = "TCP port of the appliance HTTP health listener; must match the SG module."
  type        = number
  default     = 50000
  nullable    = false
  validation {
    condition     = var.http_probe_port >= 1 && var.http_probe_port <= 65535 && floor(var.http_probe_port) == var.http_probe_port
    error_message = "http_probe_port must be an integer from 1 through 65535."
  }
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health probes required for a healthy target (2-10)."
  type        = number
  default     = 2
  nullable    = false
  validation {
    condition     = var.healthy_threshold >= 2 && var.healthy_threshold <= 10 && floor(var.healthy_threshold) == var.healthy_threshold
    error_message = "healthy_threshold must be an integer from 2 through 10."
  }
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health probes required for an unhealthy target (2-10)."
  type        = number
  default     = 3
  nullable    = false
  validation {
    condition     = var.unhealthy_threshold >= 2 && var.unhealthy_threshold <= 10 && floor(var.unhealthy_threshold) == var.unhealthy_threshold
    error_message = "unhealthy_threshold must be an integer from 2 through 10."
  }
}

variable "cross_zone_lb_enabled" {
  description = "Enable cross-zone GWLB forwarding; inter-AZ transfer charges may apply."
  type        = bool
  default     = false
  nullable    = false
}

variable "gwlb_name" {
  description = "AWS GWLB name, 1-32 alphanumeric or hyphen characters, without boundary hyphens or the reserved internal- prefix."
  type        = string
  nullable    = false
}

variable "target_group_name" {
  description = "AWS IP target group name, 1-32 alphanumeric or hyphen characters without boundary hyphens."
  type        = string
  nullable    = false
}

variable "deregistration_delay" {
  description = "Target deregistration drain delay in seconds (0-3600)."
  type        = number
  default     = 0
  nullable    = false
}

variable "flow_stickiness" {
  description = "Flow affinity: 5-tuple (default), 3-tuple (source/destination IP and protocol), or 2-tuple (source/destination IP)."
  type        = string
  default     = "5-tuple"
  nullable    = false
  validation {
    condition     = contains(["2-tuple", "3-tuple", "5-tuple"], var.flow_stickiness)
    error_message = "flow_stickiness must be 2-tuple, 3-tuple or 5-tuple."
  }
}

variable "rebalance_enabled" {
  description = "Rebalance existing flows on target deregistration or unhealthy state; otherwise retain existing target affinity."
  type        = bool
  default     = true
  nullable    = false
}

variable "tags" {
  description = "Tags applied to GWLB and the target group."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "name_prefix" {
  description = "Legacy compatibility input; resource names are controlled by gwlb_name and target_group_name, not this value."
  type        = string
  default     = "inspection"
  nullable    = false
}

variable "cc_service_ips" {
  description = "Distinct Cloud Connector service-interface IPv4 target addresses; target order is stable and caller-managed."
  type        = list(string)
  nullable    = false
}
