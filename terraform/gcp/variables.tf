variable "source_code_repo_url" {
  type        = string
  description = "Repository where IaC and Lambda function source code resides"
}

variable "environment" {
  description = "Environment the infrastructure is deployed in"
  type        = string
}

variable "cost_centre" {
  description = "Cost Centre tag value to be charged to"
  type        = string
}

variable "gcp_org_id" {
  description = "GCP Organizational ID"
  type        = string
}

##############################GCP VPC Variables####################################
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

################################VM Variables####################################
variable "cc_vm_prov_url" {
  type        = string
  description = "Zscaler Cloud Connector Provisioning URL"
}

variable "secret_name" {
  type        = string
  description = "GCP Secret Manager friendly name. Not required if using HashiCorp Vault"
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
############################GCP LB Variables####################################
variable "health_check_interval" {
  type        = number
  description = "Interval for ILB health check probing, in seconds, of Cloud Connector targets"
  default     = 10
}

variable "healthy_threshold" {
  type        = number
  description = "The number of successful health checks required before an unhealthy target becomes healthy. Minimum 2 and maximum 10"
  default     = 2
}

variable "unhealthy_threshold" {
  type        = number
  description = "The number of unsuccessful health checks required before an healthy target becomes unhealthy. Minimum 2 and maximum 10"
  default     = 3
}

variable "session_affinity" {
  type        = string
  description = "Controls the distribution of new connections from clients to the load balancer's backend VMs"
  default     = "CLIENT_IP"
  validation {
    condition = (
      var.session_affinity == "CLIENT_IP_NO_DESTINATION" ||
      var.session_affinity == "CLIENT_IP" ||
      var.session_affinity == "CLIENT_IP_PROTO" ||
      var.session_affinity == "NONE"
    )
    error_message = "Input session_affinity must be set to either CLIENT_IP_NO_DESTINATION, CLIENT_IP, CLIENT_IP_PROTO, or NONE."
  }
}

variable "allow_global_access" {
  type        = bool
  description = "true: Clients can access ILB from all regions; false: Only allow access from clients in the same region as the internal load balancer."
  default     = true
}

variable "ilb_backend_service_name" {
  type        = string
  description = "Name of the resource."
}

variable "ilb_health_check_name" {
  type        = string
  description = " Name of the resource."
}

variable "ilb_frontend_ip_name" {
  type        = string
  description = "Name of the resource."
}

variable "ilb_forwarding_rule_name" {
  type        = string
  description = "Name of the resource."
}

variable "fw_ilb_health_check_name" {
  type        = string
  description = "Name of the firewall rule created with ILB permitting GCP health check probe source ranges on the configured HTTP probe port inbound to the Cloud Connector service interface(s)"
}
