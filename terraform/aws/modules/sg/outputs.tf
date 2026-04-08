output "mgmt_security_group_id" {
  description = "Instance Management Security Group ID"
  value       = aws_security_group.cc_mgmt_sg.id
}

output "service_security_group_id" {
  description = "Instance Service Security Group ID"
  value       =  aws_security_group.cc_service_sg.id
}

output "app_connector_security_group_id" {
  description = "App Connector Service Security Group ID"
  value       =  aws_security_group.ac_sg.id
}