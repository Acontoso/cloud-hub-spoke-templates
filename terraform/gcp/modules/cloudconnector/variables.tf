variable "name_prefix" {
  type        = string
  description = "Lowercase prefix applied to Cloud Connector instance templates, instance groups, and derived names. Must satisfy Google Cloud resource-naming rules (lowercase letters, numbers, hyphens; start with a letter; at most 40 characters)."
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 40
    error_message = "name_prefix must be 1-40 characters and valid for Google Cloud resource names."
  }
}

variable "project" {
  type        = string
  description = "Google Cloud project ID where Cloud Connector resources are created."
  validation {
    condition     = length(trimspace(var.project)) > 0
    error_message = "project must be a non-empty Google Cloud project ID."
  }
}

variable "region" {
  type        = string
  description = "Google Cloud region for the Cloud Connector instance template and zonal instance groups."
  default     = "australia-southeast1"
  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "region must be a non-empty Google Cloud region such as australia-southeast1."
  }
}

variable "cc_vm_prov_url" {
  type        = string
  description = "Zscaler Cloud Connector provisioning URL injected into appliance user data."
  validation {
    condition     = length(trimspace(var.cc_vm_prov_url)) > 0
    error_message = "cc_vm_prov_url must be a non-empty provisioning URL."
  }
}

variable "secret_name" {
  type        = string
  description = "Secret Manager secret name containing provisioning material. Leave null when using HashiCorp Vault or another secret store."
  default     = null
}

variable "secret_project" {
  type        = string
  description = "Project that contains secret_name. Defaults to project when null."
  default     = null
}

variable "target_ip_address" {
  type        = string
  description = "Reserved internal address of the load balancer VIP. Supplied by the root module so appliances and the load balancer share the same value."
  default     = null
  validation {
    condition     = var.target_ip_address == null || can(cidrhost("${var.target_ip_address}/32", 0))
    error_message = "target_ip_address must be a valid IP address when set."
  }
}

variable "service_sub_network" {
  type        = string
  description = "Self link or ID of the service subnetwork attached to the Cloud Connector service interface."
  validation {
    condition     = length(trimspace(var.service_sub_network)) > 0
    error_message = "service_sub_network must not be empty."
  }
}

variable "mgmt_sub_network" {
  type        = string
  description = "Self link or ID of the management subnetwork attached to the Cloud Connector management interface."
  validation {
    condition     = length(trimspace(var.mgmt_sub_network)) > 0
    error_message = "mgmt_sub_network must not be empty."
  }
}

variable "zones" {
  type        = list(string)
  description = "Optional explicit zones for the zonal instance groups. When set, this list determines the number of instance groups and az_count is ignored."
  default     = []
  validation {
    condition = alltrue([
      for zone in var.zones :
      startswith(zone, "${var.region}-")
    ])
    error_message = "Every zone must belong to var.region, for example australia-southeast1-a when region is australia-southeast1."
  }
}

variable "http_probe_port" {
  type        = number
  description = "Port enabled by Cloud Connector cloud-init for HTTP health probes from the internal load balancer."
  default     = 50000
  validation {
    condition     = var.http_probe_port == 80 || (var.http_probe_port >= 1024 && var.http_probe_port <= 65535)
    error_message = "http_probe_port must be 80 or a number between 1024 and 65535."
  }
}

variable "az_count" {
  type        = number
  description = "Number of zonal instance groups to create when zones is empty. Ignored when explicit zones are supplied."
  default     = 3
  validation {
    condition     = length(var.zones) > 0 || (var.az_count >= 1 && var.az_count <= 3)
    error_message = "az_count must be between 1 and 3 when zones is empty. Supply explicit zones to use more than three zonal instance groups."
  }
}

variable "instance_template_name" {
  type        = string
  description = "Optional base name for the instance template. Must satisfy Google Cloud resource-naming rules (lowercase letters, numbers, hyphens). A unique suffix is generated so template replacement cannot collide with the existing template."
  default     = null
  validation {
    condition     = var.instance_template_name == null || var.instance_template_name == "" || length(var.instance_template_name) <= 53
    error_message = "instance_template_name must be at most 53 characters and valid for Google Cloud resource names."
  }
}

variable "ccvm_instance_type" {
  type        = string
  description = "Cloud Connector machine type."
  default     = "n2-standard-2"
  validation {
    condition = contains([
      "e2-standard-2",
      "e2-standard-4",
      "e2-standard-8",
      "n2-standard-2",
      "n2-standard-4",
      "n2-standard-8",
      "n2d-standard-2",
      "n2d-standard-4",
      "n2d-standard-8",
    ], var.ccvm_instance_type)
    error_message = "ccvm_instance_type must be one of the approved Cloud Connector machine types."
  }
}

variable "ssh_key" {
  type        = string
  description = "OpenSSH public key installed for the zsroot user on Cloud Connector instances."
  validation {
    condition     = length(trimspace(var.ssh_key)) > 0
    error_message = "ssh_key must be a non-empty OpenSSH public key."
  }
}

variable "service_account_id" {
  type        = string
  description = "Optional Google service account account_id. Must satisfy Google Cloud service account ID rules (6-30 characters; lowercase letters, digits, hyphens). When null, a valid ID is derived from name_prefix."
  default     = null
  validation {
    condition     = var.service_account_id == null || var.service_account_id == "" || (length(var.service_account_id) >= 6 && length(var.service_account_id) <= 30)
    error_message = "service_account_id must be 6-30 characters and valid for Google Cloud service account IDs."
  }
}

variable "service_account_display_name" {
  type        = string
  description = "Optional display name for the Cloud Connector service account."
  default     = null
}

variable "cc_count" {
  type        = number
  description = "Number of Cloud Connector appliances to create in each zonal instance group."
  default     = 1
  validation {
    condition     = var.cc_count >= 1
    error_message = "cc_count must be at least 1."
  }
}

variable "update_policy_type" {
  type        = string
  description = "Instance group update policy type. PROACTIVE applies updates automatically; OPPORTUNISTIC applies them during other actions."
  default     = "OPPORTUNISTIC"
  validation {
    condition     = var.update_policy_type == "PROACTIVE" || var.update_policy_type == "OPPORTUNISTIC"
    error_message = "update_policy_type must be either PROACTIVE or OPPORTUNISTIC."
  }
}

variable "update_policy_replacement_method" {
  type        = string
  description = "Instance replacement method. Stateful MIGs, which this module always configures for the boot disk and both internal IPs, require RECREATE."
  default     = "RECREATE"
  validation {
    condition     = var.update_policy_replacement_method == "RECREATE"
    error_message = "Stateful MIGs require update_policy_replacement_method = RECREATE."
  }
}

variable "update_policy_max_surge_fixed" {
  type        = number
  description = "Maximum number of instances created above target size during an update. Stateful MIGs do not support surge, so this must be 0."
  default     = 0
  validation {
    condition     = var.update_policy_max_surge_fixed == 0
    error_message = "Stateful MIGs do not support surge; update_policy_max_surge_fixed must be 0."
  }
}

variable "update_max_unavailable_fixed" {
  type        = number
  description = "Maximum number of instances that can be unavailable during an update. Must be greater than 0 when replacement_method is RECREATE."
  default     = 1
  validation {
    condition     = var.update_max_unavailable_fixed >= 1
    error_message = "update_max_unavailable_fixed must be at least 1."
  }
}

variable "stateful_delete_rule" {
  type        = string
  description = "Delete rule for stateful disks and internal IPs. NEVER detaches state when an instance is deleted; ON_PERMANENT_INSTANCE_DELETION deletes it with the instance."
  default     = "ON_PERMANENT_INSTANCE_DELETION"
  validation {
    condition     = contains(["NEVER", "ON_PERMANENT_INSTANCE_DELETION"], var.stateful_delete_rule)
    error_message = "stateful_delete_rule must be NEVER or ON_PERMANENT_INSTANCE_DELETION."
  }
}

variable "target_tags" {
  type        = list(string)
  description = "Network tags applied to Cloud Connector service interfaces. The internal load balancer uses the same tags for health check and backend firewall rules."
  default     = ["nva-backend"]
  validation {
    condition     = length(var.target_tags) > 0
    error_message = "target_tags must contain at least one network tag."
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels applied to the Cloud Connector instance template."
  default     = {}
}

variable "source_image_project" {
  type        = string
  description = "Project that publishes the Zscaler Cloud Connector image."
  default     = "mpi-zscalercloudconnector-publ"
  validation {
    condition     = length(trimspace(var.source_image_project)) > 0
    error_message = "source_image_project must not be empty."
  }
}

variable "source_image_name" {
  type        = string
  description = "Name of the Zscaler Cloud Connector image to use for the instance template."
  default     = "zs-cc-ga-02022025"
  validation {
    condition     = length(trimspace(var.source_image_name)) > 0
    error_message = "source_image_name must not be empty."
  }
}

variable "enable_partner_integrations" {
  type        = bool
  description = "When true, grants partner_integrations_pubsub_role to the Cloud Connector service account at project scope. Prefer partner_integrations_pubsub_topics for least-privilege access."
  default     = false
}

variable "partner_integrations_pubsub_role" {
  type        = string
  description = "Pub/Sub role granted for partner integrations. Use the narrowest role that meets the integration requirement."
  default     = "roles/pubsub.publisher"
  validation {
    condition = contains([
      "roles/pubsub.publisher",
      "roles/pubsub.subscriber",
      "roles/pubsub.viewer",
      "roles/pubsub.editor",
    ], var.partner_integrations_pubsub_role)
    error_message = "partner_integrations_pubsub_role must be a supported Pub/Sub role."
  }
}

variable "partner_integrations_pubsub_topics" {
  type        = list(string)
  description = "Optional Pub/Sub topic names that receive a topic-scoped grant of partner_integrations_pubsub_role for the Cloud Connector service account."
  default     = []
  validation {
    condition     = alltrue([for topic in var.partner_integrations_pubsub_topics : length(trimspace(topic)) > 0])
    error_message = "partner_integrations_pubsub_topics must not contain empty topic names."
  }
}
