output "vpc_id" {
  description = "Inspection VPC ID."
  value       = module.network.vpc_id
}

output "cloud_connector_subnet_ids" {
  description = "Cloud Connector subnet IDs, in selected AZ order."
  value       = module.network.cc_subnet_ids
}

output "workload_subnet_ids" {
  description = "Workload subnet IDs, in selected AZ order."
  value       = module.network.workload_subnet_ids
}

output "transit_gateway_subnet_ids" {
  description = "Reserved TGW subnets for a caller-managed VPC attachment."
  value       = module.network.tgw_subnet_ids
}

output "gwlb_arn" {
  description = "Gateway Load Balancer ARN."
  value       = module.gwlb.gwlb_arn
}

output "inspection_endpoint_ids" {
  description = "Inspection VPC endpoint IDs, in selected AZ order."
  value       = module.gwlb_endpoint.endpoint_ids
}

output "cloud_connector_instance_ids" {
  description = "Ordered Cloud Connector instance IDs."
  value       = module.cc_vm.instance_ids
}

output "app_connector_instance_ids" {
  description = "Ordered App Connector instance IDs."
  value       = module.appconnector_vm.instance_ids
}
