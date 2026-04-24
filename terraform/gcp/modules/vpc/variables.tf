variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the module resources"
  default     = null
}

variable "project" {
  type        = string
  description = "Google Cloud project name"
}

variable "region" {
  type        = string
  description = "Google Cloud region"
  default     = "australia-southeast1"
}

variable "subnet_cc_service" {
  type        = string
  description = "A subnet IP CIDR for the Cloud Connector/Load Balancer in the Service VPC. This value will be ignored if byo_service_subnet_name is set to true"
}

variable "subnet_mgmt" {
  type        = string
  description = "A subnet IP CIDR for the Cloud Connector/Load Balancer in the Service VPC. This value will be ignored if byo_service_subnet_name is set to true"
}

variable "routing_mode" {
  type        = string
  default     = "REGIONAL"
  description = "The network-wide routing mode to use. If set to REGIONAL, this network's cloud routers will only advertise routes with subnetworks of this network in the same region as the router. If set to GLOBAL, this network's cloud routers will advertise routes with all subnetworks of this network, across regions. Possible values are: REGIONAL, GLOBAL"
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the internal load balancer"
}
