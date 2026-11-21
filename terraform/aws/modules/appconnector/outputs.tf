output "instance_ids" {
  description = "Ordered App Connector instance IDs."
  value       = aws_instance.ac_vm[*].id
}

output "private_ips" {
  description = "Ordered App Connector private IPv4 addresses."
  value       = aws_instance.ac_vm[*].private_ip
}

output "role_arn" {
  description = "Dedicated App Connector bootstrap role ARN."
  value       = aws_iam_role.appconnector.arn
}
