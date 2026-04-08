output "forwarding_ip" {
  description = "Instance Forwarding/Service IP"
  value       = aws_instance.cc_vm[*].private_ip
}
