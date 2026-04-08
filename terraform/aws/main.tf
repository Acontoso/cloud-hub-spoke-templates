locals {
  tags = merge(
    {
      "env"       = "${var.environment}"
      "terraform" = "true"
      "bu"        = "security"
      "RepoUrl"   = "${var.source_code_repo_url}"
      "service"   = "inspection-vpc"
      "author"    = "alex skoro"
    }
  )
  aws_region = "ap-southeast-2"
}

locals {
  userdata = <<USERDATA
[ZSCALER]
CC_URL=${var.cc_vm_prov_url}
SECRET_NAME=${var.secret_name}
HTTP_PROBE_PORT=${var.http_probe_port}
USERDATA
}

locals {
  appuserdata = <<APPUSERDATA
#!/bin/bash
#Stop the App Connector service which was auto-started at boot time
systemctl stop zpa-connector
#Create a file from the App Connector provisioning key created in the ZPA Admin Portal
#Make sure that the provisioning key is between double quotes
echo "${data.aws_ssm_parameter.zpa_provisioning_key.value}" > /opt/zscaler/var/provision_key

#Run a yum update to apply the latest patches
yum update -y

#Start the App Connector service to enroll it in the ZPA cloud
systemctl start zpa-connector

#Wait for the App Connector to download latest build
sleep 60

#Stop and then start the App Connector for the latest build
systemctl stop zpa-connector
systemctl start zpa-connector
APPUSERDATA
}

module "network" {
  source            = "./modules/vpc"
  vpc_cidr          = var.vpc_cidr
  name_prefix       = var.name_prefix
  public_subnets    = var.public_subnets
  cc_subnets        = var.cc_subnets
  workload_subnets  = var.workload_subnets
  tgw_subnets       = var.tgw_subnets
  az_count          = var.az_count
  static_routes_tgw = var.static_routes_tgw
  tags              = local.tags
}

module "securitygroups" {
  source          = "./modules/sg"
  vpc_id          = module.network.vpc_id
  http_probe_port = var.http_probe_port
  name_prefix     = var.name_prefix
  tags            = local.tags
}

module "iam" {
  source      = "./modules/iam"
  name_prefix = var.name_prefix
  tags        = local.tags
}

module "cc_vm" {
  source                     = "./modules/cloudconnector"
  name_prefix                = var.name_prefix
  tags                       = local.tags
  ccvm_instance_type         = var.ccvm_instance_type
  ebs_encryption_enabled     = var.ebs_encryption_enabled
  cc_count                   = var.cc_count
  userdata                   = local.userdata
  aws_cc_subnet_ids          = module.network.cc_subnet_ids
  service_interface_sg_id    = module.securitygroups.cc_service_sg_id
  management_interface_sg_id = module.securitygroups.cc_mgmt_sg_id
  instance_key               = var.instance_key
}

module "gwlb" {
  source                = "./modules/gwlb"
  name_prefix           = var.name_prefix
  tags                  = local.tags
  target_group_name     = var.target_group_name
  http_probe_port       = var.http_probe_port
  healthy_threshold     = var.healthy_threshold
  unhealthy_threshold   = var.unhealthy_threshold
  health_check_interval = var.health_check_interval
  cross_zone_lb_enabled = var.cross_zone_lb_enabled
  flow_stickiness       = var.flow_stickiness
  gwlb_name             = var.gwlb_name
  cc_service_ips        = module.cc_vm.forwarding_ip
}

module "gwlb_endpoint" {
  source            = "./modules/gwlb-endpoint"
  name_prefix       = var.name_prefix
  tags              = local.tags
  aws_cc_subnet_ids = module.network.cc_subnet_ids
  vpc_id            = module.network.vpc_id
  gwlb_arn          = module.gwlb.gwlb_arn
}

module "appconnector_vm" {
  source                     = "./modules/appconnector"
  name_prefix                = var.name_prefix
  tags                       = local.tags
  acvm_instance_type         = var.acvm_instance_type
  ac_count                   = var.ac_count
  appuserdata                = local.appuserdata
  app_connector_sg_id        = module.securitygroups.app_connector_security_group_id
  aws_workload_subnet_ids    = module.network.workload_subnet_ids
  app_instance_key           = var.app_instance_key
}
