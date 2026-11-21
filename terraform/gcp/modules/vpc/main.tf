module "vpc_service" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 18.0"

  project_id   = var.project
  network_name = "${var.name_prefix}-hub-service-vpc"
  description  = "VPC for hosting Zscaler Cloud Connector service interface and load balancer."
  routing_mode = var.routing_mode

  shared_vpc_host = false
}

################################################################################
# Create CC service VPC router
################################################################################
resource "google_compute_router" "service_vpc_router" {
  name    = "${var.name_prefix}-hub-vpc-router"
  project = var.project
  region  = var.region
  network = module.vpc_service.network_self_link
}

################################################################################
# Create CC service VPC NAT gateway - multi-zone out of the box
################################################################################
resource "google_compute_router_nat" "service_vpc_nat_gateway" {
  name                               = "${var.name_prefix}-service-vpc-nat-gw"
  project                            = var.project
  router                             = google_compute_router.service_vpc_router.name
  region                             = google_compute_router.service_vpc_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  enable_dynamic_port_allocation     = true

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

module "vpc_service_subnets" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "~> 18.0"

  project_id   = var.project
  network_name = module.vpc_service.network_name

  subnets = [
    {
      subnet_name           = "${var.name_prefix}-service-subnet-01"
      subnet_ip             = var.subnet_cc_service
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Primary subnet used for the Cloud Connector service interface and load balancer VIP."
    }
  ]
}

################################################################################
# Firewall rules for the CC service VPC
################################################################################
resource "google_compute_firewall" "allow_cc_outbound_all" {
  name        = "${var.name_prefix}-zscaler-cc-outbound-access"
  description = "Allow Cloud Connector service interfaces outbound on all ports and protocols."
  project     = var.project
  network     = module.vpc_service.network_self_link

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }

  direction = "EGRESS"
  allow {
    protocol = "all"
  }
  destination_ranges = ["0.0.0.0/0"]
}

module "vpc_mgmt" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 18.0"

  project_id   = var.project
  network_name = "${var.name_prefix}-hub-mgmt-vpc"
  description  = "VPC for the Cloud Connector management interface and Zscaler Support remote assistance."
  routing_mode = var.routing_mode

  shared_vpc_host = false
}

################################################################################
# Create CC management VPC router
################################################################################
resource "google_compute_router" "mgmt_vpc_router" {
  name    = "${var.name_prefix}-mgmt-vpc-router"
  project = var.project
  region  = var.region
  network = module.vpc_mgmt.network_self_link
}

################################################################################
# Create CC management VPC NAT gateway - multi-zone out of the box
################################################################################
resource "google_compute_router_nat" "mgmt_vpc_nat_gateway" {
  name                               = "${var.name_prefix}-mgmt-vpc-nat-gw"
  project                            = var.project
  router                             = google_compute_router.mgmt_vpc_router.name
  region                             = google_compute_router.mgmt_vpc_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  enable_dynamic_port_allocation     = true

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

module "vpc_mgmt_subnets" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "~> 18.0"

  project_id   = var.project
  network_name = module.vpc_mgmt.network_name

  subnets = [
    {
      subnet_name           = "${var.name_prefix}-mgmt-subnet-01"
      subnet_ip             = var.subnet_mgmt
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Subnet used for the Cloud Connector management interface and Zscaler Support remote assistance."
    }
  ]
}

resource "google_compute_firewall" "allow_mgmt_outbound" {
  name        = "${var.name_prefix}-mgmt-allow-egress"
  description = "Standard outbound HTTP/HTTPS, DNS, and NTP access for the management VPC."
  project     = var.project
  network     = module.vpc_mgmt.network_self_link
  direction   = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  # NTP and DNS are UDP services; the previous single TCP rule used an
  # incorrect protocol for NTP.
  allow {
    protocol = "udp"
    ports    = ["53", "123"]
  }

  # DNS over TCP fallback.
  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "zsssupport_tunnel_cc_mgmt" {
  name        = "${var.name_prefix}-zscaler-support"
  description = "Allows Cloud Connector to establish the Zscaler Support remote-assistance tunnel."
  project     = var.project
  network     = module.vpc_mgmt.network_self_link
  direction   = "EGRESS"
  allow {
    protocol = "tcp"
    ports    = ["12002"]
  }
  destination_ranges = ["199.168.148.101/32"]
}
