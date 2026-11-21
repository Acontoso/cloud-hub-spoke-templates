locals {
  tags = merge(
    {
      env         = var.environment
      terraform   = "true"
      service     = "inspection-vpc"
      cost_centre = var.cost_centre
    },
    var.source_code_repo_url == null ? {} : { Repository = var.source_code_repo_url },
    var.tags,
  )

  # Only secret identifiers are rendered here; the appliance retrieves the value.
  userdata = <<-USERDATA
    [ZSCALER]
    CC_URL=${var.cc_vm_prov_url}
    SECRET_NAME=${var.secret_name}
    HTTP_PROBE_PORT=${var.http_probe_port}
  USERDATA
}

module "network" {
  source                  = "./modules/vpc"
  name_prefix             = var.name_prefix
  vpc_cidr                = var.vpc_cidr
  public_subnets          = var.public_subnets
  cc_subnets              = var.cc_subnets
  workload_subnets        = var.workload_subnets
  tgw_subnets             = var.tgw_subnets
  az_count                = var.az_count
  availability_zones      = var.availability_zones
  transit_gateway_id      = var.transit_gateway_id
  static_routes_tgw       = var.static_routes_tgw
  flow_logs_enabled       = var.flow_logs_enabled
  flow_log_retention_days = var.flow_log_retention_days
  tags                    = local.tags
}

module "securitygroups" {
  source           = "./modules/sg"
  name_prefix      = var.name_prefix
  vpc_id           = module.network.vpc_id
  vpc_cidr         = var.vpc_cidr
  management_cidrs = var.management_cidrs
  http_probe_port  = var.http_probe_port
  tags             = local.tags
}

module "iam" {
  source             = "./modules/iam"
  name_prefix        = var.name_prefix
  secret_name        = var.secret_name
  secret_kms_key_arn = var.secret_kms_key_arn
  tags               = local.tags
}

module "cc_vm" {
  source                     = "./modules/cloudconnector"
  name_prefix                = var.name_prefix
  ccvm_instance_type         = var.ccvm_instance_type
  ami_id                     = var.cc_ami_id
  ebs_encryption_enabled     = var.ebs_encryption_enabled
  kms_key_arn                = var.ebs_kms_key_arn
  ebs_volume_type            = var.ebs_volume_type
  cc_count                   = var.cc_count
  userdata                   = local.userdata
  iam_instance_profile_name  = module.iam.iam_instance_profile_name
  aws_cc_subnet_ids          = module.network.cc_subnet_ids
  service_interface_sg_id    = module.securitygroups.service_security_group_id
  management_interface_sg_id = module.securitygroups.mgmt_security_group_id
  instance_key               = var.instance_key
  tags                       = local.tags

  # Bootstrap requires working egress, not merely a created subnet.
  depends_on = [module.network]
}

module "gwlb" {
  source                = "./modules/gwlb"
  name_prefix           = var.name_prefix
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.cc_subnet_ids
  target_group_name     = coalesce(var.target_group_name, "${var.name_prefix}-cc-tg")
  gwlb_name             = coalesce(var.gwlb_name, "${var.name_prefix}-gwlb")
  http_probe_port       = var.http_probe_port
  healthy_threshold     = var.healthy_threshold
  unhealthy_threshold   = var.unhealthy_threshold
  health_check_interval = var.health_check_interval
  cross_zone_lb_enabled = var.cross_zone_lb_enabled
  flow_stickiness       = var.flow_stickiness
  deregistration_delay  = var.deregistration_delay
  rebalance_enabled     = var.rebalance_enabled
  cc_service_ips        = module.cc_vm.forwarding_ip
  tags                  = local.tags
}

module "gwlb_endpoint" {
  source            = "./modules/gwlb-endpoint"
  name_prefix       = var.name_prefix
  aws_cc_subnet_ids = module.network.cc_subnet_ids
  vpc_id            = module.network.vpc_id
  gwlb_arn          = module.gwlb.gwlb_arn
  tags              = local.tags
}

# Endpoint routes belong here: feeding endpoints back into VPC would create a cycle.
resource "aws_route" "tgw_route_vpc_endpoint" {
  count                  = var.az_count
  route_table_id         = module.network.tgw_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = module.gwlb_endpoint.endpoint_ids[count.index]

  lifecycle {
    precondition {
      condition     = length(module.network.tgw_route_table_ids) == length(module.gwlb_endpoint.endpoint_ids)
      error_message = "Transit Gateway route tables and inspection endpoints must have matching AZ-ordered cardinality."
    }
  }
}

module "appconnector_vm" {
  source                      = "./modules/appconnector"
  name_prefix                 = var.name_prefix
  acvm_instance_type          = var.acvm_instance_type
  ami_id                      = var.ac_ami_id
  ac_count                    = var.ac_count
  provisioning_parameter_name = var.ssm_zpa_provisioning_key
  provisioning_kms_key_arn    = var.app_provisioning_kms_key_arn
  ebs_kms_key_arn             = var.ebs_kms_key_arn
  app_connector_sg_id         = module.securitygroups.app_connector_security_group_id
  aws_workload_subnet_ids     = module.network.workload_subnet_ids
  app_instance_key           = var.app_instance_key
  tags                       = local.tags

  depends_on = [module.network]
}
