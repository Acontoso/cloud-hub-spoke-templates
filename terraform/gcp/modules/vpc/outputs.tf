output "service_network" {
  value       = module.vpc_service.network_self_link
  description = "The VPC service network created"
}

output "mgmt_network" {
  value       = module.vpc_mgmt.network_self_link
  description = "The VPC management network created"
}

output "service_network_subnets" {
  value       = module.vpc_service.subnets
  description = "The VPC service network subnets created"
}

output "mgmt_network_subnets" {
  value       = module.vpc_mgmt.subnets
  description = "The VPC management network subnets created"
}
