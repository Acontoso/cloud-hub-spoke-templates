locals {
  secret_enabled = var.secret_name != null && trimspace(var.secret_name) != ""

  resolved_service_account_id = coalesce(
    var.service_account_id,
    trim(substr("cc-${var.name_prefix}-ccvm", 0, 30), "-"),
  )

  resolved_service_account_display_name = coalesce(
    var.service_account_display_name,
    "Zscaler Cloud Connector",
  )

  userdata = jsonencode({
    cc_url              = var.cc_vm_prov_url
    secret_name         = local.secret_enabled ? var.secret_name : ""
    http_probe_port     = var.http_probe_port
    gcp_service_account = google_service_account.service_account_ccvm.email
    lb_vip              = var.target_ip_address == null ? "" : var.target_ip_address
  })

  template_name_base   = coalesce(var.instance_template_name, "${var.name_prefix}-cc-template")
  template_name_prefix = "${substr(local.template_name_base, 0, 53)}-"

  zone_names = length(var.zones) > 0 ? var.zones : data.google_compute_zones.available[0].names
  zone_count = length(var.zones) > 0 ? length(var.zones) : var.az_count
}

data "google_compute_image" "zs_cc_img" {
  project = var.source_image_project
  name    = var.source_image_name
}

data "google_compute_zones" "available" {
  count   = length(var.zones) == 0 ? 1 : 0
  project = var.project
  region  = var.region
  status  = "UP"
}

################################################################################
# Service account assigned to Cloud Connector appliances
################################################################################
resource "google_service_account" "service_account_ccvm" {
  account_id   = local.resolved_service_account_id
  display_name = local.resolved_service_account_display_name
  description  = "Service account used by Zscaler Cloud Connector appliances."
  project      = var.project
}

################################################################################
# Grant the service account access to the provisioning secret
################################################################################
resource "google_secret_manager_secret_iam_member" "member" {
  count = local.secret_enabled ? 1 : 0

  # Use the secret's project ID (not the numeric project number) so the IAM
  # binding targets the correct project when the secret lives elsewhere.
  project   = coalesce(var.secret_project, var.project)
  secret_id = var.secret_name
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service_account_ccvm.email}"
}

################################################################################
# Optional partner integrations access
#
# Pub/Sub access is no longer granted unconditionally. Callers can opt in to a
# narrow project-level role and/or topic-scoped grants. Topic-scoped grants are
# preferred for least privilege.
################################################################################
resource "google_project_iam_member" "partner_integrations" {
  count = var.enable_partner_integrations ? 1 : 0

  project = var.project
  role    = var.partner_integrations_pubsub_role
  member  = "serviceAccount:${google_service_account.service_account_ccvm.email}"
}

resource "google_pubsub_topic_iam_member" "partner_integrations" {
  for_each = toset(var.partner_integrations_pubsub_topics)

  project = var.project
  topic   = each.value
  role    = var.partner_integrations_pubsub_role
  member  = "serviceAccount:${google_service_account.service_account_ccvm.email}"
}

################################################################################
# Cloud Connector instance template
################################################################################
resource "google_compute_instance_template" "cc_instance_template" {
  name_prefix = local.template_name_prefix
  description = "Zscaler Cloud Connector instance template."
  project     = var.project
  region      = var.region

  machine_type   = var.ccvm_instance_type
  can_ip_forward = true
  tags           = var.target_tags

  disk {
    source_image = data.google_compute_image.zs_cc_img.self_link
    device_name  = "persistent-disk-0"
    auto_delete  = true
    boot         = true
    disk_type    = "pd-balanced"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  network_interface {
    name       = "nic0"
    subnetwork = var.service_sub_network
  }

  network_interface {
    name       = "nic1"
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
# Zonal managed instance groups
#
# Stateful disks and internal IPs pin appliance identity across repairs. GCP
# requires RECREATE replacement and does not support surge for stateful MIGs;
# both constraints are enforced through variable validation.
################################################################################
resource "google_compute_instance_group_manager" "cc_instance_group_manager" {
  count = local.zone_count

  name    = "${var.name_prefix}-cc-mig-az-${count.index + 1}"
  project = var.project
  zone    = local.zone_names[count.index]

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
    device_name = "persistent-disk-0"
    delete_rule = var.stateful_delete_rule
  }

  stateful_internal_ip {
    interface_name = "nic0"
    delete_rule    = var.stateful_delete_rule
  }

  stateful_internal_ip {
    interface_name = "nic1"
    delete_rule    = var.stateful_delete_rule
  }

  lifecycle {
    create_before_destroy = true
  }
}
