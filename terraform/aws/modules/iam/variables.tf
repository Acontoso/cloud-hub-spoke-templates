variable "name_prefix" {
  description = "Prefix for the Cloud Connector IAM role, policies, and instance profile."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Tags applied to IAM resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "secret_name" {
  description = "Existing Secrets Manager friendly name; only metadata is read by Terraform."
  type        = string
  nullable    = false
}

variable "secret_kms_key_arn" {
  description = "Optional customer-managed KMS key ARN encrypting the provisioning secret."
  type        = string
  default     = null
}
