output "endpoint_ids" {
  description = "GWLB endpoint IDs ordered exactly like aws_cc_subnet_ids, for same-AZ route wiring."
  value       = tolist(aws_vpc_endpoint.gwlb_vpce[*].id)
}

output "service_name" {
  description = "Published GWLB endpoint service name."
  value       = aws_vpc_endpoint_service.gwlb_vpce_service.service_name
}

output "service_id" {
  description = "GWLB endpoint service ID."
  value       = aws_vpc_endpoint_service.gwlb_vpce_service.id
}
