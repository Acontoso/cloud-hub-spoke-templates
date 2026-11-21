# Cloud Connector Module

Creates the Cloud Connector service account, optional secret and Pub/Sub IAM,
a replacement-safe instance template, and one zonal managed instance group per
selected zone.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name_prefix` | `string` | yes | Lowercase prefix for derived names. |
| `project` | `string` | yes | Google Cloud project ID. |
| `region` | `string` | no | Region for the template and MIGs. |
| `cc_vm_prov_url` | `string` | yes | Provisioning URL injected into user data. |
| `secret_name` | `string` | no | Secret Manager secret for provisioning material. |
| `secret_project` | `string` | no | Project containing the secret. Defaults to `project`. |
| `target_ip_address` | `string` | no | Reserved ILB VIP shared with the load balancer. |
| `service_sub_network` | `string` | yes | Service subnetwork self link/ID. |
| `mgmt_sub_network` | `string` | yes | Management subnetwork self link/ID. |
| `zones` | `list(string)` | no | Explicit zones; overrides `az_count`. |
| `az_count` | `number` | no | Number of zones when `zones` is empty. |
| `http_probe_port` | `number` | no | HTTP health probe port. |
| `instance_template_name` | `string` | no | Base template name; a unique suffix is added. |
| `ccvm_instance_type` | `string` | no | Approved Cloud Connector machine type. |
| `ssh_key` | `string` | yes | OpenSSH public key for `zsroot`. |
| `service_account_id` | `string` | no | Validated custom account ID; derived when omitted. |
| `service_account_display_name` | `string` | no | Optional display name. |
| `cc_count` | `number` | no | Appliances per zone. |
| `update_policy_type` | `string` | no | `PROACTIVE` or `OPPORTUNISTIC`. |
| `update_policy_replacement_method` | `string` | no | Must be `RECREATE` for stateful MIGs. |
| `update_policy_max_surge_fixed` | `number` | no | Must be `0` for stateful MIGs. |
| `update_max_unavailable_fixed` | `number` | no | Must be at least `1`. |
| `stateful_delete_rule` | `string` | no | `NEVER` or `ON_PERMANENT_INSTANCE_DELETION`. |
| `target_tags` | `list(string)` | no | Network tags for service interfaces. |
| `labels` | `map(string)` | no | Labels for the instance template. |
| `source_image_project` | `string` | no | Image project. |
| `source_image_name` | `string` | no | Image name. |
| `enable_partner_integrations` | `bool` | no | Opt in to a project-level Pub/Sub role. |
| `partner_integrations_pubsub_role` | `string` | no | Narrow Pub/Sub role. |
| `partner_integrations_pubsub_topics` | `list(string)` | no | Topic-scoped grants. |

## Outputs

| Name | Description |
|------|-------------|
| `instance_group_urls` | Zonal MIG `instance_group` URLs, ready for LB backends. |
| `instance_group_names` | Zonal MIG names. |
| `service_account_email` | Cloud Connector service account email. |
| `instance_template_id` | Instance template ID. |
| `zones` | Zones used by the MIGs. |
