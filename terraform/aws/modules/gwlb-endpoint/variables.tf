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

variable "aws_cc_subnet_ids" {
  type        = list(string)
  description = "List of Subnet ID to create GLWB Endpoints in"
}

variable "vpc_id" {
  type        = string
  description = "Cloud Connector VPC ID"
}

variable "gwlb_arn" {
  type        = string
  description = "ARN of GWLB for Endpoint Service to be assigned"
}
