variable "vpc_cidr" {
  description = "CIDR to allocate VPC too"
  type        = string
}

variable "name_prefix" {
  type        = string
  description = "A prefix to associate to all the network module resources"
  default     = null
}

variable "public_subnets" {
  type        = list(string)
  description = "Public/NAT GW Subnets to create in Inspection VPC"
  default     = null
}

variable "cc_subnets" {
  type        = list(string)
  description = "Cloud Connector Subnets to create in Inspection VPC"
  default     = null
}

variable "workload_subnets" {
  type        = list(string)
  description = "Workload Subnets to create in Inspection VPC"
  default     = null
}

variable "tgw_subnets" {
  type        = list(string)
  description = "TGW Subnets to create in Inspection VPC"
  default     = null
}

variable "az_count" {
  type        = number
  description = "Default number of subnets to create based on availability zone input"
  default     = 3
  validation {
    condition = (
      (var.az_count >= 1 && var.az_count <= 3)
    )
    error_message = "Input az_count must be set to a single value between 1 and 3. Note* some regions have greater than 3 AZs. Please modify az_count validation in variables.tf if you are utilizing more than 3 AZs in a region that supports it. https://aws.amazon.com/about-aws/global-infrastructure/regions_az/."
  }
}

variable "static_routes_tgw" {
  type        = list(string)
  description = "List of routes that are available through transit gateway"
  default     = null
}

variable "tags" {
  description = "Generic tags map"
  type        = map(string)
  default     = {}
}
