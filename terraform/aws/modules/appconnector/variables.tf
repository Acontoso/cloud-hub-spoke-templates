variable "name_prefix" {
  description = "Prefix for App Connector instances and their dedicated IAM identity."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Additional resource tags."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "ac_count" {
  description = "Total App Connector count, distributed round-robin across workload subnets."
  type        = number
  default     = 2

  validation {
    condition     = var.ac_count >= 1 && var.ac_count == floor(var.ac_count)
    error_message = "ac_count must be a positive integer."
  }
}

variable "acvm_instance_type" {
  description = "Marketplace-compatible x86 App Connector instance type."
  type        = string
  default     = "t3.medium"

  validation {
    condition = contains([
      "t3.medium", "t3.large", "t3.xlarge", "t3a.medium", "t3a.large", "t3a.xlarge", "t3a.2xlarge",
      "m5.large", "m5.xlarge", "m5.2xlarge", "m5.4xlarge", "m5a.large", "m5a.xlarge", "m5a.2xlarge",
      "m5a.4xlarge", "m5n.large", "m5n.xlarge", "m5n.2xlarge", "m5n.4xlarge",
    ], var.acvm_instance_type)
    error_message = "Choose a supported App Connector instance type."
  }
}

variable "ami_id" {
  description = "Pinned regional App Connector AMI ID. Null discovers the latest subscribed Marketplace image."
  type        = string
  default     = null
}

variable "app_instance_key" {
  description = "Optional existing EC2 key-pair name. Null disables key-pair injection."
  type        = string
  default     = null
}

variable "app_connector_sg_id" {
  description = "Security group attached to App Connector instances."
  type        = string
  nullable    = false
}

variable "aws_workload_subnet_ids" {
  description = "Ordered non-empty workload subnet list used for round-robin placement."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.aws_workload_subnet_ids) > 0 && length(distinct(var.aws_workload_subnet_ids)) == length(var.aws_workload_subnet_ids)
    error_message = "aws_workload_subnet_ids must contain at least one subnet without duplicates."
  }
}

variable "provisioning_parameter_name" {
  description = "Name/path of an existing local-account SSM SecureString parameter; never its value."
  type        = string
  nullable    = false
}

variable "provisioning_kms_key_arn" {
  description = "Optional customer-managed KMS key ARN encrypting the SSM SecureString parameter."
  type        = string
  default     = null
}

variable "ebs_kms_key_arn" {
  description = "Optional customer-managed EBS key ARN. Null uses the account default EBS key."
  type        = string
  default     = null
}
