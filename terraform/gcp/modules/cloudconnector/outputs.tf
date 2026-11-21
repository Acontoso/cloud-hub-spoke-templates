output "instance_group_urls" {
  description = "Instance group URLs for all zonal Cloud Connector managed instance groups. These URLs are ready to use as load balancer backends."
  value       = google_compute_instance_group_manager.cc_instance_group_manager[*].instance_group
}

output "instance_group_names" {
  description = "Names of the zonal Cloud Connector managed instance groups."
  value       = google_compute_instance_group_manager.cc_instance_group_manager[*].name
}

output "service_account_email" {
  description = "Email of the service account used by Cloud Connector VMs."
  value       = google_service_account.service_account_ccvm.email
}

output "instance_template_id" {
  description = "ID of the Cloud Connector instance template."
  value       = google_compute_instance_template.cc_instance_template.id
}

output "zones" {
  description = "Zones used by the zonal Cloud Connector managed instance groups."
  value       = local.zone_names
}
