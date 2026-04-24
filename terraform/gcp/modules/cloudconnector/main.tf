locals {
  userdata = <<USERDATA
{
  "cc_url": "${var.cc_vm_prov_url}",
  "secret_name": "${var.secret_name}",
  "http_probe_port": ${var.http_probe_port},
  "gcp_service_account": "${google_service_account.service_account_ccvm.email}",
  "lb_vip": "${var.target_ip_address}"
}
USERDATA
}

data "google_compute_image" "zs_cc_img" {
  project = "mpi-zscalercloudconnector-publ"
  name    = "zs-cc-ga-02022025"
}

data "google_compute_zones" "available" {
  status = "UP"
}

################################################################################
# Create Service Account to be assigned to Cloud Connector appliances
################################################################################
resource "google_service_account" "service_account_ccvm" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  project      = var.project
}

################################################################################
# Assign Service Account access to provided Secret Manager resource
################################################################################
resource "google_secret_manager_secret_iam_member" "member" {
  secret_id = var.secret_name
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service_account_ccvm.email}"
  project   = data.google_project.project.number
}

################################################################################
# Assign Service Account access to provided Pub/Sub editor for Partner Integrations
################################################################################
resource "google_project_iam_member" "partner_integrations_role" {
  project = data.google_project.project.number
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:${google_service_account.service_account_ccvm.email}"
}

locals {
  zones_list = slice(data.google_compute_zones.available.names, 0, var.az_count)
}

################################################################################
# Create Cloud Connector Instance Template
################################################################################
resource "google_compute_instance_template" "cc_instance_template" {
  name        = var.instance_template_name
  project     = var.project
  region      = var.region

  machine_type   = var.ccvm_instance_type
  can_ip_forward = true
  tags           = ["nva-backend"]

  disk {
    source_image = data.google_compute_image.zs_cc_img.self_link
    auto_delete  = true
    boot         = true
    disk_type    = "pd-balanced"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  network_interface {
    subnetwork = var.service_sub_network
  }

  network_interface {
    subnetwork = var.mgmt_sub_network
  }

  metadata = {
    ssh-keys                = "zsroot:${var.ssh_key}"
    ZSCALER                 = local.userdata
    enable-guest-attributes = "TRUE"
  }

  service_account {
    email  = google_service_account.service_account_ccvm.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
  labels = var.labels
}


################################################################################
# Create Zonal Managed Instance Groups per number of zones defined
# Create X number of Cloud Connectors in each group per cc_count variable
################################################################################
resource "google_compute_instance_group_manager" "cc_instance_group_manager" {
  count   = var.az_count
  name    = "${var.name_prefix}-cc-mig-az-${count.index + 1}"
  project = var.project
  zone    = element(local.zones_list, count.index)

  base_instance_name = "${var.name_prefix}-mig-az-${count.index + 1}-ccvm"
  version {
    instance_template = google_compute_instance_template.cc_instance_template.id
  }
  target_size = var.cc_count

  update_policy {
    type                           = var.update_policy_type
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = var.update_policy_max_surge_fixed
    max_unavailable_fixed          = var.update_max_unavailable_fixed
    replacement_method             = var.update_policy_replacement_method
  }

  stateful_disk {
    device_name = google_compute_instance_template.cc_instance_template.disk[0].device_name
    delete_rule = var.stateful_delete_rule
  }

  stateful_internal_ip {
    interface_name = google_compute_instance_template.cc_instance_template.network_interface[0].name
    delete_rule    = var.stateful_delete_rule
  }

  stateful_internal_ip {
    interface_name = google_compute_instance_template.cc_instance_template.network_interface[1].name
    delete_rule    = var.stateful_delete_rule
  }

  lifecycle {
    create_before_destroy = true
  }
}


################################################################################
# Wait for Instance Group creation to collect individual compute details
################################################################################
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [google_compute_instance_group_manager.cc_instance_group_manager]
  create_duration = "60s"
}

data "google_compute_instance_group" "cc_instance_groups" {
  count     = length(google_compute_instance_group_manager.cc_instance_group_manager[*].instance_group)
  self_link = element(google_compute_instance_group_manager.cc_instance_group_manager[*].instance_group, count.index)

  depends_on = [
    time_sleep.wait_60_seconds
  ]
}
