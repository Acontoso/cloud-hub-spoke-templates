output "vpc_id" {
  description = "ID of the inspection VPC."
  value       = aws_vpc.vpc.id
}

output "cc_subnet_ids" {
  description = "Cloud Connector subnet IDs in input CIDR/AZ order."
  value       = aws_subnet.cc_subnet[*].id
}

output "public_subnet_ids" {
  description = "Public/NAT subnet IDs in input CIDR/AZ order."
  value       = aws_subnet.public_subnet[*].id
}

output "workload_subnet_ids" {
  description = "Workload subnet IDs in input CIDR/AZ order."
  value       = aws_subnet.workload_subnet[*].id
}

output "tgw_subnet_ids" {
  description = "TGW attachment subnet IDs in input CIDR/AZ order."
  value       = aws_subnet.tgw_subnet[*].id
}

output "tgw_route_table_ids" {
  description = "TGW subnet route table IDs in input CIDR/AZ order; caller owns endpoint default routes."
  value       = aws_route_table.tgw_rt[*].id
}

output "cc_route_table_ids" {
  description = "Cloud Connector route table IDs in input CIDR/AZ order."
  value       = aws_route_table.cc_rt[*].id
}

output "workload_route_table_ids" {
  description = "Workload route table IDs in input CIDR/AZ order."
  value       = aws_route_table.workload_rt[*].id
}

output "flow_log_group_name" {
  description = "CloudWatch flow log group name, or null when logging is disabled."
  value       = one(aws_cloudwatch_log_group.flow_logs[*].name)
}

output "instance_connect_security_group_id" {
  description = "Instance Connect endpoint SG; allow this SG as an SSH source on target instances if required."
  value       = aws_security_group.ec2_instance_endpoint_security_group.id
}
