output "service_network_name" {
  description = "Name of the service VPC network."
  value       = module.vpc_service.network_name
}

output "service_network_self_link" {
  description = "Self link of the service VPC network."
  value       = module.vpc_service.network_self_link
}

output "service_network_id" {
  description = "ID of the service VPC network."
  value       = module.vpc_service.network_id
}

output "service_subnet_name" {
  description = "Name of the Cloud Connector service subnet."
  value       = values(module.vpc_service_subnets.subnets)[0].name
}

output "service_subnet_self_link" {
  description = "Self link of the Cloud Connector service subnet."
  value       = values(module.vpc_service_subnets.subnets)[0].self_link
}

output "service_subnet_id" {
  description = "ID of the Cloud Connector service subnet."
  value       = values(module.vpc_service_subnets.subnets)[0].id
}

output "mgmt_network_name" {
  description = "Name of the management VPC network."
  value       = module.vpc_mgmt.network_name
}

output "mgmt_network_self_link" {
  description = "Self link of the management VPC network."
  value       = module.vpc_mgmt.network_self_link
}

output "mgmt_network_id" {
  description = "ID of the management VPC network."
  value       = module.vpc_mgmt.network_id
}

output "mgmt_subnet_name" {
  description = "Name of the Cloud Connector management subnet."
  value       = values(module.vpc_mgmt_subnets.subnets)[0].name
}

output "mgmt_subnet_self_link" {
  description = "Self link of the Cloud Connector management subnet."
  value       = values(module.vpc_mgmt_subnets.subnets)[0].self_link
}

output "mgmt_subnet_id" {
  description = "ID of the Cloud Connector management subnet."
  value       = values(module.vpc_mgmt_subnets.subnets)[0].id
}
