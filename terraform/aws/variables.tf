variable "aws_region" {
  description = "AWS region for all resources in this deployment."
  type        = string
  default     = "ap-southeast-2"
  nullable    = false

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be an AWS region identifier."
  }
}

variable "name_prefix" {
  description = "Short deployment prefix used in resource names."
  type        = string
  default     = "inspection"
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,19}$", var.name_prefix))
    error_message = "name_prefix must be 2–20 alphanumeric/hyphen characters starting with a letter."
  }
}

variable "environment" {
  description = "Environment classification, for example development, staging, or production."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "environment must not be empty."
  }
}

variable "cost_centre" {
  description = "Cost allocation identifier."
  type        = string
  default     = "unassigned"
  nullable    = false
}

variable "source_code_repo_url" {
  description = "Optional repository URL recorded as a resource tag."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags; caller values override deployment-level defaults."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "vpc_cidr" {
  description = "IPv4 CIDR allocated to the inspection VPC."
  type        = string
  nullable    = false

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR."
  }
}

variable "public_subnets" {
  description = "One public NAT subnet CIDR per selected AZ, in AZ order."
  type        = list(string)
  nullable    = false
}

variable "cc_subnets" {
  description = "One Cloud Connector and GWLB endpoint subnet CIDR per AZ, in AZ order."
  type        = list(string)
  nullable    = false
}

variable "workload_subnets" {
  description = "One workload/App Connector subnet CIDR per AZ, in AZ order."
  type        = list(string)
  nullable    = false
}

variable "tgw_subnets" {
  description = "One reserved Transit Gateway attachment subnet CIDR per AZ, in AZ order."
  type        = list(string)
  nullable    = false
}

variable "az_count" {
  description = "Number of availability zones. Use at least two for an available deployment."
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 6 && var.az_count == floor(var.az_count)
    error_message = "az_count must be an integer from 1 to 6."
  }
}

variable "availability_zones" {
  description = "Optional explicit AZ order. Empty discovers available AZs; pin this for existing deployments."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "transit_gateway_id" {
  description = "Existing Transit Gateway ID. The gateway, VPC attachment, and TGW routing are caller-managed."
  type        = string
  default     = null
}

variable "static_routes_tgw" {
  description = "Non-default IPv4 destinations routed to the existing TGW from private route tables."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "management_cidrs" {
  description = "Explicit private-source CIDR allowlist for appliance SSH. Empty creates no SSH ingress rules."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "flow_logs_enabled" {
  description = "Enable inspection VPC flow logs in CloudWatch Logs; incurs logging charges."
  type        = bool
  default     = true
  nullable    = false
}

variable "flow_log_retention_days" {
  description = "CloudWatch retention period for VPC flow logs."
  type        = number
  default     = 30
}

variable "cc_vm_prov_url" {
  description = "HTTPS Cloud Connector provisioning URL from the Zscaler portal."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^https://[^[:space:]]+$", var.cc_vm_prov_url))
    error_message = "cc_vm_prov_url must be an HTTPS URL without whitespace."
  }
}

variable "secret_name" {
  description = "Existing Secrets Manager provisioning-secret name; never supply the secret value."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9/_+=.@-]+$", var.secret_name))
    error_message = "secret_name must be a non-empty Secrets Manager friendly name without whitespace."
  }
}

variable "secret_kms_key_arn" {
  description = "Optional customer-managed KMS key ARN encrypting the Cloud Connector secret."
  type        = string
  default     = null
}

variable "ccvm_instance_type" {
  description = "Cloud Connector instance type matching its Zscaler provisioning template."
  type        = string
  default     = "m6i.large"
}

variable "cc_count" {
  description = "Total Cloud Connector count. Placement cycles through the selected subnets."
  type        = number
  default     = 3

  validation {
    condition     = var.cc_count >= var.az_count && var.cc_count == floor(var.cc_count)
    error_message = "cc_count must be an integer providing at least one connector per selected AZ."
  }
}

variable "cc_ami_id" {
  description = "Optional pinned regional Cloud Connector AMI. Null discovers the latest Marketplace image."
  type        = string
  default     = null
}

variable "instance_key" {
  description = "Optional existing Cloud Connector EC2 key-pair name."
  type        = string
  default     = null
}

variable "ebs_encryption_enabled" {
  description = "Encrypt Cloud Connector root volumes. App Connector root volumes are always encrypted."
  type        = bool
  default     = true
  nullable    = false
}

variable "ebs_kms_key_arn" {
  description = "Optional customer-managed EBS key ARN shared by appliance root volumes."
  type        = string
  default     = null
}

variable "ebs_volume_type" {
  description = "Cloud Connector root-volume type: gp2 or gp3."
  type        = string
  default     = "gp3"
}

variable "http_probe_port" {
  description = "Cloud Connector HTTP health-probe port; also rendered into appliance bootstrap."
  type        = number
  default     = 50000

  validation {
    condition     = var.http_probe_port >= 1 && var.http_probe_port <= 65535 && var.http_probe_port == floor(var.http_probe_port)
    error_message = "http_probe_port must be an integer from 1 to 65535."
  }
}

variable "gwlb_name" {
  description = "Optional GWLB name. Null derives a name from name_prefix."
  type        = string
  default     = null
}

variable "target_group_name" {
  description = "Optional GWLB target-group name. Null derives a name from name_prefix."
  type        = string
  default     = null
}

variable "health_check_interval" {
  description = "GWLB health-probe interval in seconds: 10 or 30."
  type        = number
  default     = 10

  validation {
    condition     = contains([10, 30], var.health_check_interval)
    error_message = "health_check_interval must be 10 or 30 seconds."
  }
}

variable "healthy_threshold" {
  description = "Successful probes before a GWLB target becomes healthy."
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Failed probes before a GWLB target becomes unhealthy."
  type        = number
  default     = 3
}

variable "cross_zone_lb_enabled" {
  description = "Allow GWLB distribution to targets in other AZs; cross-AZ charges may apply."
  type        = bool
  default     = true
}

variable "deregistration_delay" {
  description = "GWLB target deregistration delay in seconds."
  type        = number
  default     = 30
}

variable "flow_stickiness" {
  description = "GWLB affinity tuple: 2-tuple, 3-tuple, or 5-tuple."
  type        = string
  default     = "5-tuple"
}

variable "rebalance_enabled" {
  description = "Rebalance existing flows when a GWLB target is unhealthy or deregistered."
  type        = bool
  default     = true
}

variable "ac_count" {
  description = "Total App Connector count, distributed across workload subnets."
  type        = number
  default     = 2
}

variable "acvm_instance_type" {
  description = "Marketplace-supported App Connector instance type."
  type        = string
  default     = "t3.medium"
}

variable "ac_ami_id" {
  description = "Optional pinned regional App Connector AMI. Null discovers the latest Marketplace image."
  type        = string
  default     = null
}

variable "app_instance_key" {
  description = "Optional existing App Connector EC2 key-pair name."
  type        = string
  default     = null
}

variable "ssm_zpa_provisioning_key" {
  description = "Existing SSM SecureString parameter name/path for App Connector provisioning, not its value."
  type        = string
  nullable    = false
}

variable "app_provisioning_kms_key_arn" {
  description = "Optional customer-managed KMS key ARN encrypting the App Connector parameter."
  type        = string
  default     = null
}
