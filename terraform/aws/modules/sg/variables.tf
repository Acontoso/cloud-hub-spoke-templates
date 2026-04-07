variable "vpc_id" {
  description = "ID of the VPC the security groups belong to"
  type        = string
}

variable "http_probe_port" {
  description = "Port for HTTP probe for health checks against CC instances"
  type        = string
}

variable "tags" {
  description = "Generic tags map"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the network module resources"
  default     = null
}

variable "zssupport_server" {
  type        = string
  description = "destination IP address of Zscaler Support access server. IP resolution of remotesupport.<zscaler_customer_cloud>.net"
  default     = "199.168.148.101/32" #for commercial clouds
}

