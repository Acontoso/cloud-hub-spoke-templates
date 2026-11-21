locals {
  health_check_name = coalesce(var.ilb_health_check_name, "${var.name_prefix}-ilb-health-check")
}

module "gce-ilb" {
  source  = "GoogleCloudPlatform/lb-internal/google"
  version = "~> 6.0"

  region     = var.region
  name       = "${var.name_prefix}-ilb"
  subnetwork = var.lb_sub_network
  network    = var.lb_vpc_network
  ip_address = var.target_ip_address

  all_ports                    = true
  create_health_check_firewall = true
  create_backend_firewall      = true
  global_access                = var.allow_global_access
  session_affinity             = var.session_affinity
  source_tags                  = []

  # Cloud Connector service interfaces carry this tag so the module can create
  # health check and backend firewall rules.
  target_tags = var.nva_target_tags

  health_check = {
    type                = "http"
    check_interval_sec  = var.health_check_interval
    healthy_threshold   = var.healthy_threshold
    timeout_sec         = var.health_check_timeout
    unhealthy_threshold = var.unhealthy_threshold
    port                = var.http_probe_port
    request_path        = "/?cchealth"
    name                = local.health_check_name
  }

  backends = var.backends
  labels   = var.labels
}
