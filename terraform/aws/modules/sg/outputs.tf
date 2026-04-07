output "mgmt_security_group_id" {
  description = "Instance Management Security Group ID"
  value       = aws_security_group.cc_mgmt_sg.id
}

output "service_security_group_id" {
  description = "Instance Service Security Group ID"
  value       =  aws_security_group.cc_service_sg.id
}
