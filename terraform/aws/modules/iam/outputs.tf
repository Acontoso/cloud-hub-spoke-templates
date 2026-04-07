

output "iam_instance_profile_arn" {
  description = "IAM Instance Profile ARN"
  value       =aws_iam_instance_profile.cc_host_profile.arn
}
