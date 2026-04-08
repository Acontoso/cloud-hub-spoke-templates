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

variable "ac_count" {
  type        = number
  description = "Default number of App Connector appliances to create"
  default     = 3
}

variable "app_instance_key" {
  type        = string
  description = "SSH Key for instances"
}

variable "min_size" {
  type        = number
  description = "Mininum number of App Connectors to maintain in Autoscaling group"
  default     = 1
}

variable "acvm_instance_type" {
  type        = string
  description = "App Connector Instance Type"
  default     = "t3.medium"
  validation {
    condition = (
      var.acvm_instance_type == "t3.medium" ||
      var.acvm_instance_type == "t3.large" ||
      var.acvm_instance_type == "t3.xlarge" ||
      var.acvm_instance_type == "t3a.medium" ||
      var.acvm_instance_type == "t3a.large" ||
      var.acvm_instance_type == "t3a.xlarge" ||
      var.acvm_instance_type == "t3a.2xlarge" ||
      var.acvm_instance_type == "m5.large" ||
      var.acvm_instance_type == "m5.xlarge" ||
      var.acvm_instance_type == "m5.2xlarge" ||
      var.acvm_instance_type == "m5.4xlarge" ||
      var.acvm_instance_type == "m5a.large" ||
      var.acvm_instance_type == "m5a.xlarge" ||
      var.acvm_instance_type == "m5a.2xlarge" ||
      var.acvm_instance_type == "m5a.4xlarge" ||
      var.acvm_instance_type == "m5n.large" ||
      var.acvm_instance_type == "m5n.xlarge" ||
      var.acvm_instance_type == "m5n.2xlarge" ||
      var.acvm_instance_type == "m5n.4xlarge"
    )
    error_message = "Input acvm_instance_type must be set to an approved vm instance type."
  }
}

variable "appuserdata" {
  type        = string
  description = "User data script to configure the instance to dynamically onboard the app connector into Zscaler"
}

variable "app_connector_sg_id" {
  type        = string
  description = "Security group ID for App Connector management interfaces"
}

variable "aws_workload_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to launch App Connector instances in"
}
