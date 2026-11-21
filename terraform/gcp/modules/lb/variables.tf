variable "name_prefix" {
  type        = string
  description = "Lowercase prefix used for the internal load balancer and health check names. Must satisfy Google Cloud resource-naming rules (lowercase letters, numbers, hyphens; start with a letter; at most 40 characters)."
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 40
    error_message = "name_prefix must be 1-40 characters and valid for Google Cloud resource names."
  }
}

variable "region" {
  type        = string
  description = "Google Cloud region for the regional internal load balancer."
  default     = "australia-southeast1"
  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "region must be a non-empty Google Cloud region such as australia-southeast1."
  }
}

variable "lb_vpc_network" {
  type        = string
  description = "Self link of the VPC network that contains the internal load balancer."
  validation {
    condition     = length(trimspace(var.lb_vpc_network)) > 0
    error_message = "lb_vpc_network must not be empty."
  }
}

variable "lb_sub_network" {
  type        = string
  description = "Self link of the subnetwork that contains the internal load balancer VIP and backends."
  validation {
    condition     = length(trimspace(var.lb_sub_network)) > 0
    error_message = "lb_sub_network must not be empty."
  }
}

variable "target_ip_address" {
  type        = string
  description = "Reserved internal address for the load balancer VIP. Supplied by the root module so it matches the Cloud Connector user data."
  default     = null
  validation {
    condition     = var.target_ip_address == null || can(cidrhost("${var.target_ip_address}/32", 0))
    error_message = "target_ip_address must be a valid IP address when set."
  }
}

variable "nva_target_tags" {
  type        = list(string)
  description = "Network tags on Cloud Connector service interfaces. The load balancer uses these tags for health check and backend firewall rules."
  default     = ["nva-backend"]
  validation {
    condition     = length(var.nva_target_tags) > 0
    error_message = "nva_target_tags must contain at least one network tag."
  }
}

variable "health_check_interval" {
  type        = number
  description = "Interval, in seconds, between internal load balancer health probes."
  default     = 10
  validation {
    condition     = var.health_check_interval >= 1 && var.health_check_interval <= 300
    error_message = "health_check_interval must be between 1 and 300 seconds."
  }
}

variable "health_check_timeout" {
  type        = number
  description = "Health probe timeout, in seconds."
  default     = 5
  validation {
    condition     = var.health_check_timeout >= 1 && var.health_check_timeout <= 300
    error_message = "health_check_timeout must be between 1 and 300 seconds."
  }
}

variable "healthy_threshold" {
  type        = number
  description = "Number of successful health checks required before an unhealthy target becomes healthy. Minimum 2 and maximum 10."
  default     = 2
  validation {
    condition     = var.healthy_threshold >= 2 && var.healthy_threshold <= 10
    error_message = "healthy_threshold must be between 2 and 10."
  }
}

variable "unhealthy_threshold" {
  type        = number
  description = "Number of unsuccessful health checks required before a healthy target becomes unhealthy. Minimum 2 and maximum 10."
  default     = 3
  validation {
    condition     = var.unhealthy_threshold >= 2 && var.unhealthy_threshold <= 10
    error_message = "unhealthy_threshold must be between 2 and 10."
  }
}

variable "http_probe_port" {
  type        = number
  description = "Port used for HTTP health probes of Cloud Connector targets."
  default     = 50000
  validation {
    condition     = var.http_probe_port == 80 || (var.http_probe_port >= 1024 && var.http_probe_port <= 65535)
    error_message = "http_probe_port must be 80 or a number between 1024 and 65535."
  }
}

variable "session_affinity" {
  type        = string
  description = "Distribution of new client connections across Cloud Connector backends."
  default     = "CLIENT_IP"
  validation {
    condition     = contains(["CLIENT_IP_NO_DESTINATION", "CLIENT_IP", "CLIENT_IP_PROTO", "NONE"], var.session_affinity)
    error_message = "session_affinity must be CLIENT_IP_NO_DESTINATION, CLIENT_IP, CLIENT_IP_PROTO, or NONE."
  }
}

variable "allow_global_access" {
  type        = bool
  description = "When true, clients in any region can reach the internal load balancer. When false, only clients in the load balancer region can reach it."
  default     = true
}

variable "ilb_health_check_name" {
  type        = string
  description = "Optional name for the health check. Defaults to a name derived from name_prefix."
  default     = null
}

variable "backends" {
  type = list(object({
    group       = string
    description = optional(string, "")
    failover    = optional(bool, false)
  }))
  description = "Cloud Connector instance group backends for the internal load balancer."
  validation {
    condition     = length(var.backends) > 0
    error_message = "backends must contain at least one Cloud Connector instance group."
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels applied to internal load balancer resources that support labels."
  default     = {}
}
