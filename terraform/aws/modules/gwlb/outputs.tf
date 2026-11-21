output "gwlb_arn" {
  description = "Gateway Load Balancer ARN for the endpoint service module."
  value       = aws_lb.gwlb.arn
}

output "gwlb_dns_name" {
  description = "AWS DNS name of the Gateway Load Balancer."
  value       = aws_lb.gwlb.dns_name
}

output "gwlb_arn_suffix" {
  description = "GWLB ARN suffix for CloudWatch metric dimensions."
  value       = aws_lb.gwlb.arn_suffix
}

output "target_group_arn" {
  description = "GENEVE IP target group ARN."
  value       = aws_lb_target_group.gwlb_target_group.arn
}

output "listener_arn" {
  description = "GWLB forwarding listener ARN."
  value       = aws_lb_listener.gwlb_listener.arn
}
