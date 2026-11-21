output "iam_instance_profile_arn" {
  description = "Cloud Connector instance-profile ARN."
  value       = aws_iam_instance_profile.cc_host_profile.arn
  depends_on = [
    aws_iam_role_policy_attachment.cc_get_secrets_attachment,
    aws_iam_role_policy_attachment.cc_session_manager_attachment,
    aws_iam_role_policy_attachment.cc_metrics_attachment,
  ]
}

output "iam_instance_profile_name" {
  description = "Cloud Connector instance-profile name, suitable for aws_instance."
  value       = aws_iam_instance_profile.cc_host_profile.name
  depends_on = [
    aws_iam_role_policy_attachment.cc_get_secrets_attachment,
    aws_iam_role_policy_attachment.cc_session_manager_attachment,
    aws_iam_role_policy_attachment.cc_metrics_attachment,
  ]
}

output "role_arn" {
  description = "Cloud Connector role ARN for additional caller-managed permissions."
  value       = aws_iam_role.cc_node_iam_role.arn
}
