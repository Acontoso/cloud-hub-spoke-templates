output "ip_address" {
  description = "Internal load balancer VIP address."
  value       = module.gce-ilb.ip_address
}

output "forwarding_rule_id" {
  description = "ID of the internal load balancer forwarding rule."
  value       = module.gce-ilb.forwarding_rule_id
}
