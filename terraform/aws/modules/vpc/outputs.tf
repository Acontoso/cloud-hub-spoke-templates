output "vpc_id" {
  description = "VPC ID"
  value       =  aws_vpc.vpc[0].id
}

output "cc_subnet_ids" {
  description = "Cloud Connector Subnet ID"
  value       = aws_subnet.cc_subnet[*].id
}

output "workload_subnet_ids" {
  description = "Workloads Subnet ID"
  value       = aws_subnet.workload_subnet[*].id
}

output "public_subnet_ids" {
  description = "Public Subnet ID"
  value       = aws_subnet.public_subnet[*].id
}

output "workload_route_table_ids" {
  description = "Workloads Route Table ID"
  value       = aws_route_table_association.workload_rt_association[*].route_table_id
}
