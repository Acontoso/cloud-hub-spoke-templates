variable "vpc_id" {
  description = "ID of the VPC containing the appliance interfaces."
  type        = string
  nullable    = false
}

variable "vpc_cidr" {
  description = "Canonical IPv4 CIDR of vpc_id, used for appliance cluster, health probe and GENEVE rules."
  type        = string
  nullable    = false
}

variable "management_cidrs" {
  description = "Explicit canonical IPv4 CIDRs allowed to SSH to management interfaces. Empty disables SSH ingress; 0.0.0.0/0 is prohibited."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "http_probe_port" {
  description = "TCP port used by GWLB HTTP health probes; must match the appliance listener and GWLB module."
  type        = number
  nullable    = false
}

variable "tags" {
  description = "Tags applied to security groups."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "name_prefix" {
  description = "Nonempty prefix for security group names."
  type        = string
  default     = "inspection"
  nullable    = false
}

variable "zssupport_server" {
  description = "Canonical IPv4 CIDR for the Zscaler remote support server; the commercial-cloud default may need replacement for other clouds."
  type        = string
  default     = "199.168.148.101/32"
  nullable    = false
}
