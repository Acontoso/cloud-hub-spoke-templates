locals {
  labels = merge(
    {
      terraform = "true"
    },
    var.labels,
  )
  reserved_internal_address = coalesce(
    var.reserved_internal_address,
    cidrhost(var.subnet_cc_service, -2),
  )
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix       = var.name_prefix
  project           = var.project
  region            = var.region
  subnet_cc_service = var.subnet_cc_service
  subnet_mgmt       = var.subnet_mgmt
  routing_mode      = var.routing_mode
}

module "cc" {
  source = "./modules/cloudconnector"

  name_prefix     = var.name_prefix
  project         = var.project
  region          = var.region
  service_sub_network = module.vpc.service_subnet_self_link
  mgmt_sub_network    = module.vpc.mgmt_subnet_self_link

  target_ip_address = local.reserved_internal_address
  target_tags       = var.nva_target_tags

  cc_vm_prov_url               = var.cc_vm_prov_url
  secret_name                  = var.secret_name
  secret_project               = var.secret_project
  ssh_key                      = var.ssh_key
  service_account_id           = var.service_account_id
  service_account_display_name = var.service_account_display_name
  instance_template_name       = var.instance_template_name
  source_image_project         = var.source_image_project
  source_image_name            = var.source_image_name

  ccvm_instance_type            = var.ccvm_instance_type
  cc_count                      = var.cc_count
  az_count                      = var.az_count
  zones                         = var.zones
  http_probe_port               = var.http_probe_port
  update_policy_type            = var.update_policy_type
  update_policy_replacement_method = var.update_policy_replacement_method
  update_policy_max_surge_fixed = var.update_policy_max_surge_fixed
  update_max_unavailable_fixed  = var.update_max_unavailable_fixed
  stateful_delete_rule          = var.stateful_delete_rule

  enable_partner_integrations        = var.enable_partner_integrations
  partner_integrations_pubsub_role   = var.partner_integrations_pubsub_role
  partner_integrations_pubsub_topics = var.partner_integrations_pubsub_topics

  labels = local.labels
}

module "lb" {
  source = "./modules/lb"

  name_prefix           = var.name_prefix
  region                = var.region
  lb_vpc_network        = module.vpc.service_network_self_link
  lb_sub_network        = module.vpc.service_subnet_self_link
  target_ip_address     = local.reserved_internal_address
  ilb_health_check_name = var.ilb_health_check_name

  health_check_interval = var.health_check_interval
  health_check_timeout  = var.health_check_timeout
  healthy_threshold     = var.healthy_threshold
  unhealthy_threshold   = var.unhealthy_threshold
  http_probe_port       = var.http_probe_port
  session_affinity      = var.session_affinity
  allow_global_access   = var.allow_global_access
  nva_target_tags       = var.nva_target_tags

  backends = [
    for idx, group_url in module.cc.instance_group_urls : {
      group       = group_url
      description = "Cloud Connector backend group ${idx + 1}"
      failover    = false
    }
  ]

  labels = local.labels
}
