variable "tags" {
  description = "Tags applied to the endpoint service and endpoints."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "name_prefix" {
  description = "Nonempty prefix for endpoint service and endpoint names."
  type        = string
  default     = "inspection"
  nullable    = false
}

variable "aws_cc_subnet_ids" {
  description = "Ordered distinct IPv4 subnet IDs for GWLB endpoints, one per AZ in vpc_id; order is preserved in endpoint_ids."
  type        = list(string)
  nullable    = false
}

variable "vpc_id" {
  description = "VPC ID containing all endpoint subnets."
  type        = string
  nullable    = false
}

variable "gwlb_arn" {
  description = "ARN of the Gateway Load Balancer published by this endpoint service."
  type        = string
  nullable    = false
}

variable "allowed_principals" {
  description = "Explicit IAM principal ARNs allowed to connect without acceptance. Empty defaults to this AWS account's root principal; wildcard principals are prohibited."
  type        = list(string)
  default     = []
  nullable    = false
}
