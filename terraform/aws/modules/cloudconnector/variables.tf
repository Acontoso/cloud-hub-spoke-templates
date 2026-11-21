variable "name_prefix" {
  description = "Prefix for appliance and interface names."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "ccvm_instance_type" {
  description = "Marketplace-supported instance type matching the Zscaler provisioning template."
  type        = string
  default     = "m6i.large"

  validation {
    condition     = contains(["t3.medium", "m6i.large", "c6i.large", "c6in.large", "m6i.4xlarge", "c6i.4xlarge", "c6in.4xlarge"], var.ccvm_instance_type)
    error_message = "Choose a supported Cloud Connector instance type."
  }
}

variable "cc_count" {
  description = "Total appliance count, distributed round-robin across the supplied subnets."
  type        = number
  default     = 3

  validation {
    condition     = var.cc_count >= 1 && var.cc_count == floor(var.cc_count)
    error_message = "cc_count must be a positive integer."
  }
}

variable "ami_id" {
  description = "Pinned Cloud Connector AMI ID. Null discovers the latest subscribed Marketplace image."
  type        = string
  default     = null

  validation {
    condition     = var.ami_id == null ? true : can(regex("^ami-[0-9a-f]+$", var.ami_id))
    error_message = "ami_id must be an AMI ID or null."
  }
}

variable "instance_key" {
  description = "Optional existing EC2 key-pair name. Null disables key-pair injection."
  type        = string
  default     = null
}

variable "iam_instance_profile_name" {
  description = "Existing instance-profile name granting appliance bootstrap and management permissions."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.iam_instance_profile_name)) > 0
    error_message = "iam_instance_profile_name must not be empty."
  }
}

variable "userdata" {
  description = "Raw appliance bootstrap configuration, not base64 encoded. Supply references, never secret values."
  type        = string
  sensitive   = true
  nullable    = false
}

variable "aws_cc_subnet_ids" {
  description = "Ordered non-empty subnet list; both interfaces of each appliance use its assigned subnet."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.aws_cc_subnet_ids) > 0 && length(distinct(var.aws_cc_subnet_ids)) == length(var.aws_cc_subnet_ids)
    error_message = "aws_cc_subnet_ids must contain at least one subnet without duplicates."
  }
}

variable "service_interface_sg_id" {
  description = "Security group for the forwarding interface."
  type        = string
  nullable    = false
}

variable "management_interface_sg_id" {
  description = "Security group for the management interface."
  type        = string
  nullable    = false
}

variable "ebs_encryption_enabled" {
  description = "Whether root EBS volumes are encrypted. Keep enabled outside explicitly approved exceptions."
  type        = bool
  default     = true
  nullable    = false
}

variable "kms_key_arn" {
  description = "Optional customer-managed EBS KMS key ARN. Null uses the account default EBS key."
  type        = string
  default     = null

  validation {
    condition     = var.kms_key_arn == null || var.ebs_encryption_enabled
    error_message = "A kms_key_arn requires ebs_encryption_enabled = true."
  }
}

variable "ebs_volume_type" {
  description = "General-purpose SSD root-volume type."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3"], var.ebs_volume_type)
    error_message = "ebs_volume_type must be gp2 or gp3."
  }
}
