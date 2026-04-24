variable "cc_vm_prov_url" {
  type        = string
  description = "Zscaler Cloud Connector Provisioning URL"
}

variable "secret_name" {
  type        = string
  description = "GCP Secret Manager friendly name. Not required if using HashiCorp Vault"
}

variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the module resources"
  default     = null
}

variable "project" {
  type        = string
  description = "Google Cloud project name"
}

variable "target_ip_address" {
  type        = string
  description = "The IP address to be assigned to the internal load balancer"
  default     = null
}

variable "service_sub_network" {
  type        = string
  description = "The service subnetwork in which service network interface will reside in the Cloud Connector appliance VMs"
  default     = null
}

variable "mgmt_sub_network" {
  type        = string
  description = "The management subnetwork in which management network interface will reside in the Cloud Connector appliance VMs"
  default     = null
}

variable "region" {
  type        = string
  description = "Google Cloud region"
  default     = "australia-southeast1"
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

variable "az_count" {
  type        = number
  description = "Default number zonal instance groups to create based on availability zone"
  default     = 3
  validation {
    condition = (
      (var.az_count >= 1 && var.az_count <= 3)
    )
    error_message = "Input az_count must be set to a single value between 1 and 3. Note* some regions have greater than 3 AZs. Please modify az_count validation in variables.tf if you are utilizing more than 3 AZs in a region that supports it."
  }
}

variable "instance_template_name" {
  type        = string
  description = "The name of the instance template"
}

variable "ccvm_instance_type" {
  type        = string
  description = "Cloud Connector Instance Type"
  default     = "n2-standard-2"
  validation {
    condition = (
      var.ccvm_instance_type == "e2-standard-2" ||
      var.ccvm_instance_type == "e2-standard-4" ||
      var.ccvm_instance_type == "e2-standard-8" ||
      var.ccvm_instance_type == "n2-standard-2" ||
      var.ccvm_instance_type == "n2-standard-4" ||
      var.ccvm_instance_type == "n2-standard-8" ||
      var.ccvm_instance_type == "n2d-standard-2" ||
      var.ccvm_instance_type == "n2d-standard-4" ||
      var.ccvm_instance_type == "n2d-standard-8"
    )
    error_message = "Input ccvm_instance_type must be set to an approved vm instance type."
  }
}

variable "ssh_key" {
  type        = string
  description = "SSH Key for instances"
}

variable "service_account_id" {
  type        = string
  description = "Custom Service Account ID string for Cloud Connector"
  default     = ""
}

variable "service_account_display_name" {
  type        = string
  description = "Custom Service Account display name string for Cloud Connector"
  default     = ""
}

variable "cc_count" {
  type        = number
  description = "Default number of Cloud Connector appliances to create per instance group/AVZ"
  default     = 1
}

variable "update_policy_type" {
  type        = string
  description = "The type of update process. You can specify either PROACTIVE so that the instance group manager proactively executes actions in order to bring instances to their target versions or OPPORTUNISTIC so that no action is proactively executed but the update will be performed as part of other actions (for example, resizes or recreateInstances calls)"
  default     = "OPPORTUNISTIC"
  validation {
    condition = (
      var.update_policy_type == "PROACTIVE" ||
      var.update_policy_type == "OPPORTUNISTIC"
    )
    error_message = "Input update_policy_type must be set to an approved value."
  }
}

variable "update_policy_replacement_method" {
  type        = string
  description = "The instance replacement method for managed instance groups. Valid values are: RECREATE or SUBSTITUTE. If SUBSTITUTE, the group replaces VM instances with new instances that have randomly generated names. If RECREATE, instance names are preserved. You must also set max_unavailable_fixed or max_unavailable_percent to be greater than 0"
  default     = "SUBSTITUTE"
  validation {
    condition = (
      var.update_policy_replacement_method == "RECREATE" ||
      var.update_policy_replacement_method == "SUBSTITUTE"
    )
    error_message = "Input update_policy_replacement_method must be set to an approved value."
  }
}

variable "update_policy_max_surge_fixed" {
  type        = number
  description = "The maximum number of instances that can be created above the specified targetSize during the update process. Conflicts with max_surge_percent. If neither is set, defaults to 1"
  default     = 2
}

variable "update_max_unavailable_fixed" {
  type        = number
  description = "The maximum number of instances that can be unavailable during the update process. Conflicts with max_unavailable_percent. If neither is set, defaults to 1"
  default     = 1
}

variable "stateful_delete_rule" {
  type        = string
  description = " A value that prescribes what should happen to the stateful disk when the VM instance is deleted. The available options are NEVER and ON_PERMANENT_INSTANCE_DELETION. NEVER - detach the disk when the VM is deleted, but do not delete the disk. ON_PERMANENT_INSTANCE_DELETION will delete the stateful disk when the VM is permanently deleted from the instance group."
  default     = "ON_PERMANENT_INSTANCE_DELETION"
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the internal load balancer"
}
