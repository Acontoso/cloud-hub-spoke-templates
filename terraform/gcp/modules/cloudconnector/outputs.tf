output "instance_group_urls" {
  description = "All zonal MIG instance group URLs created by this module"
  value       = google_compute_instance_group_manager.cc_instance_group_manager[*].instance_group
}
