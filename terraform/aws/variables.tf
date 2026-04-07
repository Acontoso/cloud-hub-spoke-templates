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

#####################VPC Variables##########################

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

######################Cloud Connector Variables##########################
variable "cc_vm_prov_url" {
  type        = string
  description = "Zscaler Cloud Connector Provisioning URL"
}

variable "secret_name" {
  type        = string
  description = "AWS Secrets Manager Secret Name for Cloud Connector provisioning"
}

variable "http_probe_port" {
  type        = number
  description = "Port number for Cloud Connector cloud init to enable listener port for HTTP probe from GWLB Target Group"
  default     = 50000
}

variable "cc_instance_size" {
  type        = string
  description = "Cloud Connector Instance size. Determined by and needs to match the Cloud Connector Portal provisioning template configuration"
  default     = "small"
  validation {
    condition = (
      var.cc_instance_size == "small" ||
      var.cc_instance_size == "medium" ||
      var.cc_instance_size == "large"
    )
    error_message = "Input cc_instance_size must be set to an approved cc instance type."
  }
}

variable "ccvm_instance_type" {
  type        = string
  description = "Cloud Connector Instance Type"
  default     = "m6i.large"
  validation {
    condition = (
      var.ccvm_instance_type == "t3.medium" ||
      var.ccvm_instance_type == "m6i.large" ||
      var.ccvm_instance_type == "c6i.large" ||
      var.ccvm_instance_type == "c6in.large" ||
      var.ccvm_instance_type == "m6i.4xlarge" ||
      var.ccvm_instance_type == "c6i.4xlarge" ||
      var.ccvm_instance_type == "c6in.4xlarge"
    )
    error_message = "Input ccvm_instance_type must be set to an approved vm instance type."
  }
}

variable "ebs_encryption_enabled" {
  type        = bool
  description = "true/false whether to enable EBS encryption on the root volume. Default is true"
  default     = true
}

variable "cc_count" {
  type        = number
  description = "Default number of Cloud Connector appliances to create"
  default     = 3
}

variable "zssupport_server" {
  type        = string
  description = "destination IP address of Zscaler Support access server. IP resolution of remotesupport.<zscaler_customer_cloud>.net"
  default     = "199.168.148.101/32"
}

variable "ebs_volume_type" {
  type        = string
  description = "(Optional) Type of volume. Valid values include standard, gp2, gp3, io1, io2, sc1, or st1. Defaults to gp3"
  default     = "gp3"
}

variable "instance_key" {
  type        = string
  description = "SSH Key for instances"
}

variable "min_size" {
  type        = number
  description = "Mininum number of Cloud Connectors to maintain in Autoscaling group"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maxinum number of Cloud Connectors to maintain in Autoscaling group"
  default     = 2
  validation {
    condition = (
      var.max_size >= 1 && var.max_size <= 10
    )
    error_message = "Input max_size must be set to a number between 1 and 10."
  }
}

variable "health_check_grace_period" {
  type        = number
  description = "The health check grace period specifies the minimum amount of time (in seconds) to keep a new instance in service before terminating it if it's found to be unhealthy."
  default     = 900
}

variable "instance_warmup" {
  type        = number
  description = "Amount of time, in seconds, until a newly launched instance can contribute to the Amazon CloudWatch metrics. This delay lets an instance finish initializing before Amazon EC2 Auto Scaling aggregates instance metrics, resulting in more reliable usage data. Set this value equal to the amount of time that it takes for resource consumption to become stable after an instance reaches the InService state"
  default     = 60
}

variable "health_check_type" {
  type        = string
  description = "EC2 or ELB. Controls how health checking is done"
  default     = "ELB"
  validation {
    condition = (
      var.health_check_type == "EC2" ||
      var.health_check_type == "ELB"
    )
    error_message = "Input health_check_type must be set to an approved predefined metric."
  }
}

variable "launch_template_version" {
  type        = string
  description = "Launch template version. Can be version number, `$Latest` or `$Default`"
  default     = "$Latest"
}

variable "target_cpu_util_value" {
  type        = number
  description = "Target value number for autoscaling policy CPU utilization target tracking. ie: trigger a scale in/out to keep average CPU Utliization percentage across all instances at/under this number"
  default     = 80
}

variable "lifecyclehook_instance_launch_wait_time" {
  type        = number
  description = "The maximum amount of time to wait in pending:wait state on instance launch in warmpool"
  default     = 1800
}

variable "lifecyclehook_instance_terminate_wait_time" {
  type        = number
  description = "The maximum amount of time to wait in terminating:wait state on instance termination"
  default     = 900
}

variable "protect_from_scale_in" {
  type        = bool
  description = "Whether newly launched instances are automatically protected from termination by Amazon EC2 Auto Scaling when scaling in. For more information about preventing instances from terminating on scale in, see Using instance scale-in protection in the Amazon EC2 Auto Scaling User Guide"
  default     = false
}

variable "wait_for_capacity_timeout" {
  type        = string
  description = "Maximum duration that Terraform should wait for ASG instances to be healthy before timing out"
  default     = "0"
}

variable "zonal_asg_enabled" {
  type        = bool
  description = "The number of Auto Scaling Groups to create. By default, Terraform will create a single Auto Scaling Group containing multiple subnets/availability zones. Set to true if you would rather create one Auto Scaling Group per subnet/availability zone (var.az_count)"
  default     = true
}

#######################GWLB Variables##########################

variable "health_check_interval" {
  type        = number
  description = "Interval for GWLB target group health check probing, in seconds, of Cloud Connector targets. Minimum 5 and maximum 300 seconds"
  default     = 5
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

variable "cross_zone_lb_enabled" {
  type        = bool
  description = "Determines whether GWLB cross zone load balancing should be enabled or not"
  default     = true
}

variable "gwlb_name" {
  type        = string
  description = "GWLB resource and tag name"
}

variable "target_group_name" {
  type        = string
  description = "GWLB Target Group resource name"
}

variable "deregistration_delay" {
  type        = number
  description = "Amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds."
  default     = 0
}

variable "flow_stickiness" {
  type        = string
  description = "Options are (Default) 5-tuple (src ip/src port/dest ip/dest port/protocol), 3-tuple (src ip/dest ip/protocol), or 2-tuple (src ip/dest ip)"
  default     = "5-tuple"

  validation {
    condition = (
      var.flow_stickiness == "2-tuple" ||
      var.flow_stickiness == "3-tuple" ||
      var.flow_stickiness == "5-tuple"
    )
    error_message = "Input flow_stickiness must be set to an approved value of either 5-tuple, 3-tuple, or 2-tuple."
  }
}

variable "rebalance_enabled" {
  type        = bool
  description = "Indicates how the GWLB handles existing flows when a target is deregistered or marked unhealthy. true means rebalance. false means no_rebalance. Default: true"
  default     = true
}
########################Private Access Variables##########################
variable "app_instance_key" {
  type        = string
  description = "SSH Key for instances"
}

variable "ac_count" {
  type        = number
  description = "Default number of App Connector appliances to create"
  default     = 2
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

variable "ssm_zpa_provisioning_key" {
  type        = string
  description = "SSM Parameter that stores the provisioning key for Zscaler Private Access App Connector"
}

########################ASG Lambda Variables##########################
variable "asg_lambda_filename" {
  type        = string
  description = "Name of the lambda zip file without zip suffix"
  default     = "zscaler_cc_lambda_service"
}

variable "log_group_retention_days" {
  type        = number
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0"
  default     = 3
}

variable "architecture" {
  description = "The architecture for the Lambda function (x86_64 or arm64)"
  type        = string
  default     = "x86_64"

  validation {
    condition     = contains(["x86_64", "arm64"], var.architecture)
    error_message = "Invalid architecture. Must be either 'x86_64' or 'arm64'."
  }
}

variable "runtime" {
  description = "The runtime for the Lambda function (python3.11 or python3.12)"
  type        = string
  default     = "python3.12"

  validation {
    condition     = contains(["python3.11", "python3.12"], var.runtime)
    error_message = "Invalid architecture. Must be either 'python3.11' or 'python3.12'."
  }
}