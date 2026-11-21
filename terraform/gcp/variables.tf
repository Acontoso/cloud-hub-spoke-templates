###############################################################################
# Core configuration
###############################################################################

variable "project" {
  type        = string
  description = "Google Cloud project ID where the hub resources are created."
  validation {
    condition     = length(trimspace(var.project)) > 0
    error_message = "project must be a non-empty Google Cloud project ID."
  }
}

variable "region" {
  type        = string
  description = "Google Cloud region for the VPC, Cloud Connector, and internal load balancer resources."
  default     = "australia-southeast1"
  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "region must be a non-empty Google Cloud region such as australia-southeast1."
  }
}

variable "name_prefix" {
  type        = string
  description = "Lowercase prefix used for all resources created by this configuration. Must satisfy Google Cloud resource-naming rules (lowercase letters, numbers, hyphens; start with a letter; at most 40 characters)."
  validation {
    condition     = length(var.name_prefix) > 0 && length(var.name_prefix) <= 40
    error_message = "name_prefix must be 1-40 characters and valid for Google Cloud resource names."
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels applied to resources that support labels. Values supplied here override the built-in defaults."
  default     = {}
}

###############################################################################
# VPC and subnet configuration
###############################################################################

variable "subnet_cc_service" {
  type        = string
  description = "IPv4 CIDR range for the Cloud Connector service/load balancer subnet in the service VPC."
  validation {
    condition     = can(cidrhost(var.subnet_cc_service, 0))
    error_message = "subnet_cc_service must be a valid CIDR block, for example 10.10.0.0/24."
  }
}

variable "subnet_mgmt" {
  type        = string
  description = "IPv4 CIDR range for the Cloud Connector management subnet in the management VPC."
  validation {
    condition     = can(cidrhost(var.subnet_mgmt, 0))
    error_message = "subnet_mgmt must be a valid CIDR block, for example 10.10.1.0/24."
  }
}

variable "routing_mode" {
  type        = string
  description = "Network-wide routing mode for the service and management VPCs. Possible values are REGIONAL and GLOBAL."
  default     = "REGIONAL"
  validation {
    condition     = var.routing_mode == "REGIONAL" || var.routing_mode == "GLOBAL"
    error_message = "routing_mode must be either REGIONAL or GLOBAL."
  }
}

variable "reserved_internal_address" {
  type        = string
  description = "Reserved internal IP address, inside subnet_cc_service, used as the internal load balancer VIP. The same address is passed to the Cloud Connector user data and to the internal load balancer. Defaults to the second-to-last usable address in subnet_cc_service."
  default     = null
  validation {
    condition     = var.reserved_internal_address == null || can(cidrhost("${var.reserved_internal_address}/32", 0))
    error_message = "reserved_internal_address must be a valid IPv4 address inside subnet_cc_service."
  }
}

variable "nva_target_tags" {
  type        = list(string)
  description = "Network tags applied to Cloud Connector service interfaces and used by the internal load balancer firewall rules."
  default     = ["nva-backend"]
  validation {
    condition     = length(var.nva_target_tags) > 0
    error_message = "nva_target_tags must contain at least one network tag."
  }
}

###############################################################################
# Cloud Connector VM configuration
###############################################################################

variable "cc_vm_prov_url" {
  type        = string
  description = "Zscaler Cloud Connector provisioning URL."
  validation {
    condition     = length(trimspace(var.cc_vm_prov_url)) > 0
    error_message = "cc_vm_prov_url must be a non-empty provisioning URL."
  }
}

variable "secret_name" {
  type        = string
  description = "Secret Manager secret name containing the Cloud Connector provisioning material. Leave null when using a different secret store such as HashiCorp Vault."
  default     = null
}

variable "secret_project" {
  type        = string
  description = "Project that contains secret_name. Defaults to project when null."
  default     = null
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
  description = "Optional Google service account account_id for Cloud Connector VMs. Must satisfy Google Cloud service account ID rules (6-30 characters; lowercase letters, digits, hyphens). When null, a valid ID is derived from name_prefix."
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

variable "instance_template_name" {
  type        = string
  description = "Optional base name for the Cloud Connector instance template. Must satisfy Google Cloud resource-naming rules (lowercase letters, numbers, hyphens). A unique suffix is generated so template replacement does not collide with the existing template."
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

variable "cc_count" {
  type        = number
  description = "Number of Cloud Connector appliances to create in each zonal instance group."
  default     = 1
  validation {
    condition     = var.cc_count >= 1
    error_message = "cc_count must be at least 1."
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

variable "zones" {
  type        = list(string)
  description = "Optional explicit zones for the zonal instance groups, for example [\"australia-southeast1-a\", \"australia-southeast1-b\"]. When set, this list determines the number of instance groups and az_count is ignored."
  default     = []
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

variable "update_policy_type" {
  type        = string
  description = "Instance group update policy type. PROACTIVE applies updates automatically; OPPORTUNISTIC applies them during other actions such as resize or recreateInstances."
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

###############################################################################
# Partner integrations (opt-in Pub/Sub access)
###############################################################################

variable "enable_partner_integrations" {
  type        = bool
  description = "When true, grants partner_integrations_pubsub_role to the Cloud Connector service account at project scope. Prefer partner_integrations_pubsub_topics for least-privilege, topic-scoped access."
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
  description = "Optional Pub/Sub topic names that receive a topic-scoped grant of partner_integrations_pubsub_role for the Cloud Connector service account. Prefer this over project-scoped access."
  default     = []
  validation {
    condition     = alltrue([for topic in var.partner_integrations_pubsub_topics : length(trimspace(topic)) > 0])
    error_message = "partner_integrations_pubsub_topics must not contain empty topic names."
  }
}

###############################################################################
# Internal load balancer configuration
###############################################################################

variable "ilb_health_check_name" {
  type        = string
  description = "Optional name for the internal load balancer health check. Defaults to a name derived from name_prefix."
  default     = null
}

variable "health_check_interval" {
  type        = number
  description = "Interval, in seconds, between internal load balancer health probes of Cloud Connector targets."
  default     = 10
  validation {
    condition     = var.health_check_interval >= 1 && var.health_check_interval <= 300
    error_message = "health_check_interval must be between 1 and 300 seconds."
  }
}

variable "health_check_timeout" {
  type        = number
  description = "Health probe timeout, in seconds, for the internal load balancer."
  default     = 5
  validation {
    condition     = var.health_check_timeout >= 1 && var.health_check_timeout <= 300
    error_message = "health_check_timeout must be between 1 and 300 seconds."
  }
}

variable "healthy_threshold" {
  type        = number
  description = "Number of successful health checks required before an unhealthy target becomes healthy. Minimum 2 and maximum 10."
  default     = 2
  validation {
    condition     = var.healthy_threshold >= 2 && var.healthy_threshold <= 10
    error_message = "healthy_threshold must be between 2 and 10."
  }
}

variable "unhealthy_threshold" {
  type        = number
  description = "Number of unsuccessful health checks required before a healthy target becomes unhealthy. Minimum 2 and maximum 10."
  default     = 3
  validation {
    condition     = var.unhealthy_threshold >= 2 && var.unhealthy_threshold <= 10
    error_message = "unhealthy_threshold must be between 2 and 10."
  }
}

variable "session_affinity" {
  type        = string
  description = "Distribution of new client connections across Cloud Connector backends."
  default     = "CLIENT_IP"
  validation {
    condition     = contains(["CLIENT_IP_NO_DESTINATION", "CLIENT_IP", "CLIENT_IP_PROTO", "NONE"], var.session_affinity)
    error_message = "session_affinity must be CLIENT_IP_NO_DESTINATION, CLIENT_IP, CLIENT_IP_PROTO, or NONE."
  }
}

variable "allow_global_access" {
  type        = bool
  description = "When true, clients in any region can reach the internal load balancer. When false, only clients in the load balancer region can reach it."
  default     = true
}
