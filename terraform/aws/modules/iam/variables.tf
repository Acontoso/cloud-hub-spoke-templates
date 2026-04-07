variable "tags" {
  description = "Generic tags map"
  type        = map(string)
  default     = {}
}

variable "secret_name" {
  type        = string
  description = "Name of the secret in AWS Secrets Manager used for Cloud Connector registration to Zscaler"
  default     = null
}

variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the network module resources"
  default     = null
}
