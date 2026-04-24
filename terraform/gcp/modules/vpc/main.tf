module "vpc_service" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 18.0"

  project_id   = var.project
  network_name = "${var.name_prefix}-hub-service-vpc"
  description  = "VPC for hosting Zscaler Cloud Connector Service Interface and Load Balancer"

  shared_vpc_host = false
}

################################################################################
# Create CC Service VPC Router
################################################################################
resource "google_compute_router" "service_vpc_router" {
  name    = "${var.name_prefix}-hub-vpc-router"
  network = module.vpc_service.vpc_self_link
}

################################################################################
# Create CC Service VPC NAT Gateway - Multi AZ OOTB
################################################################################
resource "google_compute_router_nat" "service_vpc_nat_gateway" {
  name                               = "${var.name_prefix}-service-vpc-nat-gw"
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
  network_name = module.vpc_service.vpc_name

  subnets = [
    {
      subnet_name           = "${var.name_prefix}-service-subnet-01"
      subnet_ip             = var.subnet_cc_service
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "This primary subnet is used for the Cloud Connector service interface and Load Balancer VIP"
    }
  ]
}

################################################################################
# Firewall Rules for CC VPC
################################################################################
resource "google_compute_firewall" "allow_cc_outbound_all" {
  name        = "${var.name_prefix}-zscaler-cc-outbound-access"
  description = "CC outbound all ports and protocols"
  network     = module.vpc_service.vpc_self_link
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
  description  = "VPC for hosting Zscaler Cloud Connector management interface and for Zscaler Support to remotely assist with troubleshooting"

  shared_vpc_host = false
}

################################################################################
# Create CC Mgmt VPC Router
################################################################################
resource "google_compute_router" "mgmt_vpc_router" {
  name    = "${var.name_prefix}-mgmt-vpc-router"
  network = module.vpc_mgmt.vpc_self_link
}

################################################################################
# Create CC Mgmt VPC NAT Gateway - Multi AZ OOTB
################################################################################
resource "google_compute_router_nat" "mgmt_vpc_nat_gateway" {
  name                               = "${var.name_prefix}-mgmt-vpc-nat-gw"
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
  network_name = "${var.name_prefix}-hub-mgmt-vpc"

  subnets = [
    {
      subnet_name           = "${var.name_prefix}-mgmt-subnet-01"
      subnet_ip             = var.subnet_mgmt
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "This secondary subnet is used for the Cloud Connector management interface and for Zscaler Support to remotely assist with troubleshooting"
    }
  ]
}

resource "google_compute_firewall" "allow_mgmt_outbound" {
  name        = "${var.name_prefix}-mgmt-allow-egress"
  description = "Standard outbound access for management VPC."
  network     = module.vpc_mgmt.vpc_self_link
  direction   = "EGRESS"
  allow {
    protocol = "tcp"
    ports    = ["443", "80", "123"]
  }
  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "zsssupport_tunnel_cc_mgmt" {
  name        = "${var.name_prefix}-zscaler-support"
  description = "Required for Cloud Connector to establish connectivity for Zscaler Support to remotely assist"
  network     = module.vpc_mgmt.vpc_self_link
  direction   = "EGRESS"
  allow {
    protocol = "tcp"
    ports    = ["12002"]
  }
  destination_ranges = ["199.168.148.101/32"]
}
