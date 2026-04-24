variable "health_check_interval" {
  type        = number
  description = "Interval for ILB health check probing, in seconds, of Cloud Connector targets"
  default     = 10
}

variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the module resources"
  default     = null
}

variable "lb_vpc_network" {
  type        = string
  description = "The VPC network in which the internal load balancer will be created"
  default     = null
}

variable "target_ip_address" {
  type        = string
  description = "The IP address to be assigned to the internal load balancer"
  default     = null
}

variable "lb_sub_network" {
  type        = string
  description = "The subnetwork in which the internal load balancer will be created"
  default     = null
}

variable "nva_target_tags" {
  type        = list(string)
  description = "List of target tags for NVA backed VMs to allow probe and backend traffic from the ILB to NVA service interfaces"
  default     = []
}

variable "region" {
  type        = string
  description = "Google Cloud region"
  default     = "australia-southeast1"
}

variable "healthy_threshold" {
  type        = number
  description = "The number of successful health checks required before an unhealthy target becomes healthy. Minimum 2 and maximum 10"
  default     = 2
}

variable "unhealthy_threshold" {
  type        = number
  description = "The number of unsuccessful health checks required before an healthy target becomes unhealthy. Minimum 2 and maximum 10"
  default     = 3
}

variable "http_probe_port" {
  type        = number
  description = "Port number for Cloud Connector cloud init to enable listener port for HTTP probe from GCP LB"
  default     = 50000
  validation {
    condition = (
      tonumber(var.http_probe_port) == 80 ||
      (tonumber(var.http_probe_port) >= 1024 && tonumber(var.http_probe_port) <= 65535)
    )
    error_message = "Input http_probe_port must be set to a single value of 80 or any number between 1024-65535."
  }
}

variable "session_affinity" {
  type        = string
  description = "Controls the distribution of new connections from clients to the load balancer's backend VMs"
  default     = "CLIENT_IP"
  validation {
    condition = (
      var.session_affinity == "CLIENT_IP_NO_DESTINATION" ||
      var.session_affinity == "CLIENT_IP" ||
      var.session_affinity == "CLIENT_IP_PROTO" ||
      var.session_affinity == "NONE"
    )
    error_message = "Input session_affinity must be set to either CLIENT_IP_NO_DESTINATION, CLIENT_IP, CLIENT_IP_PROTO, or NONE."
  }
}

variable "allow_global_access" {
  type        = bool
  description = "true: Clients can access ILB from all regions; false: Only allow access from clients in the same region as the internal load balancer."
  default     = true
}

variable "ilb_health_check_name" {
  type        = string
  description = "Name of the health check for the internal load balancer."
}

variable "backends" {
  type        = list(object({
    group       = string
    description = string
    failover    = bool
  }))
  description = "List of backend configurations for the internal load balancer."
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the internal load balancer"
}
