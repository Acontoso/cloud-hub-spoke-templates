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

variable "userdata" {
  type        = string
  description = "User data script to configure the instance to dynamically onboard into Zscaler"
}

variable "aws_cc_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for Cloud Connector instances"
}

variable "service_interface_sg_id" {
  type        = string
  description = "Security group ID for Cloud Connector service interfaces"
}

variable "management_interface_sg_id" {
  type        = string
  description = "Security group ID for Cloud Connector management interfaces"
}
