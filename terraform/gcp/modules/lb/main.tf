module "gce-ilb" {
  source                       = "GoogleCloudPlatform/lb-internal/google"
  version                      = "~> 6.0"
  region                       = var.region
  name                         = "${var.name_prefix}-ilb"
  subnetwork                   = var.lb_sub_network
  network                      = var.lb_vpc_network
  ip_address                   = var.target_ip_address 
  all_ports                    = true
  create_health_check_firewall = true
  create_backend_firewall      = true
  global_access                = var.allow_global_access
  session_affinity             = var.session_affinity
  source_tags                  = []
  target_tags                  = var.nva_target_tags # NVA backed VMs will be added to this target tag for firewall rules to allow probe and backend traffic from the ILB to NVA service interfaces
  health_check = {
    type                = "http"
    check_interval_sec  = var.health_check_interval
    healthy_threshold   = var.healthy_threshold
    timeout_sec         = 5
    unhealthy_threshold = var.unhealthy_threshold
    port                = var.http_probe_port
    request_path        = "/?cchealth"
    name                = var.ilb_health_check_name
  }

  backends = var.backends
  labels = var.labels
}
