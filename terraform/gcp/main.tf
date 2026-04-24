locals {
  labels = merge(
    {
      "terraform" = "true"
      "bu"        = "security"
      "service"   = "gcp-hub-sse"
      "author"    = "alex skoro"
    }
  )
}

module "vpc" {
  source            = "modules/vpc"
  name_prefix       = var.name_prefix
  project           = var.project
  region            = var.region
  subnet_cc_service = var.subnet_cc_service
  subnet_mgmt       = var.subnet_mgmt
  routing_mode      = var.routing_mode
  labels            = local.labels
}

module "cc" {
  source                    = "modules/cloudconnector"
  name_prefix               = var.name_prefix
  project                   = var.project
  region                    = var.region
  service_sub_network       = module.vpc.service_network_subnets[0].self_link
  mgmt_sub_network          = module.vpc.mgmt_network_subnets[0].self_link
  ccvm_instance_type        = var.cc_vm_instance_type
  instance_template_name    = "${var.name_prefix}-cc-instance-template"
  ssh_key                   = var.ssh_key
  cc_vm_prov_url            = var.cc_vm_prov_url
  az_count                  = var.az_count
  cc_count                  = var.cc_count
  labels                    = local.labels
}

module "lb" {
  source                = "modules/lb"
  name_prefix           = var.name_prefix
  region                = var.region
  lb_vpc_network        = module.vpc.vpc_self_link
  lb_sub_network        = module.vpc.service_network_subnets[0].self_link
  ilb_health_check_name = var.ilb_health_check_name
  nva_target_tags       = ["nva-backend"]
  backends = [
    for idx, group_url in module.cc.instance_group_urls : { # take the module output, that is a list of strings
      group       = group_url
      description = "Cloud Connector backend group ${idx + 1}"
      failover    = false
    }
  ]
  labels = local.labels
}
