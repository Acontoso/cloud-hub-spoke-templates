output "forwarding_ip" {
  description = "Ordered service-interface IPv4 addresses for GWLB target registration."
  value       = aws_network_interface.cc_vm_nic_index_0[*].private_ip
}

output "instance_ids" {
  description = "Ordered Cloud Connector instance IDs."
  value       = aws_instance.cc_vm[*].id
}

output "management_ips" {
  description = "Ordered management-interface private IPv4 addresses."
  value       = aws_network_interface.cc_vm_nic_index_1[*].private_ip
}
