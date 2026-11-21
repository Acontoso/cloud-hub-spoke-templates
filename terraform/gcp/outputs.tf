output "service_network_name" {
  description = "Name of the service VPC network."
  value       = module.vpc.service_network_name
}

output "service_network_self_link" {
  description = "Self link of the service VPC network."
  value       = module.vpc.service_network_self_link
}

output "service_network_id" {
  description = "ID of the service VPC network."
  value       = module.vpc.service_network_id
}

output "service_subnet_name" {
  description = "Name of the Cloud Connector service subnet."
  value       = module.vpc.service_subnet_name
}

output "service_subnet_self_link" {
  description = "Self link of the Cloud Connector service subnet."
  value       = module.vpc.service_subnet_self_link
}

output "service_subnet_id" {
  description = "ID of the Cloud Connector service subnet."
  value       = module.vpc.service_subnet_id
}

output "mgmt_network_name" {
  description = "Name of the management VPC network."
  value       = module.vpc.mgmt_network_name
}

output "mgmt_network_self_link" {
  description = "Self link of the management VPC network."
  value       = module.vpc.mgmt_network_self_link
}

output "mgmt_network_id" {
  description = "ID of the management VPC network."
  value       = module.vpc.mgmt_network_id
}

output "mgmt_subnet_name" {
  description = "Name of the Cloud Connector management subnet."
  value       = module.vpc.mgmt_subnet_name
}

output "mgmt_subnet_self_link" {
  description = "Self link of the Cloud Connector management subnet."
  value       = module.vpc.mgmt_subnet_self_link
}

output "mgmt_subnet_id" {
  description = "ID of the Cloud Connector management subnet."
  value       = module.vpc.mgmt_subnet_id
}

output "reserved_internal_address" {
  description = "Reserved internal address shared by the internal load balancer VIP and the Cloud Connector user data."
  value       = local.reserved_internal_address
}

output "cloud_connector_instance_group_urls" {
  description = "Instance group URLs for the zonal Cloud Connector managed instance groups."
  value       = module.cc.instance_group_urls
}

output "cloud_connector_service_account_email" {
  description = "Email of the service account used by Cloud Connector VMs."
  value       = module.cc.service_account_email
}

output "cloud_connector_instance_template_id" {
  description = "ID of the Cloud Connector instance template."
  value       = module.cc.instance_template_id
}

output "cloud_connector_zones" {
  description = "Zones used by the Cloud Connector zonal managed instance groups."
  value       = module.cc.zones
}

output "load_balancer_ip_address" {
  description = "Internal load balancer VIP address."
  value       = module.lb.ip_address
}

output "load_balancer_forwarding_rule_id" {
  description = "ID of the internal load balancer forwarding rule."
  value       = module.lb.forwarding_rule_id
}
