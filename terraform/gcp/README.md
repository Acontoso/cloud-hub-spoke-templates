# GCP Hub and Spoke Template

Terraform configuration for a Zscaler Cloud Connector hub in Google Cloud. It
creates two VPCs (service and management), zonal Cloud Connector managed
instance groups, and an internal load balancer that fronts the appliance
service interfaces.

## Architecture

- **Service VPC** (`subnet_cc_service`): Cloud Connector service interfaces,
  internal load balancer VIP, and default egress through Cloud NAT.
- **Management VPC** (`subnet_mgmt`): Cloud Connector management interfaces,
  restricted egress for HTTP/HTTPS, DNS, NTP, and Zscaler Support.
- **Zonal MIGs**: one managed instance group per selected zone. Each group has
  `cc_count` appliances.
- **Internal load balancer**: regional, with the Cloud Connector instance group
  URLs as backends and the appliance health endpoint `/?cchealth` as the probe.
- **Shared VIP**: the root module resolves one reserved internal address and
  passes it to both the Cloud Connector user data (`lb_vip`) and the internal
  load balancer (`ip_address`).

## Layout

```text
terraform/gcp/
  main.tf
  variables.tf
  outputs.tf
  versions.tf
  terraform.tfvars.example
  env/
    dev.tfvars
    prod.tfvars
  modules/
    vpc/
    cloudconnector/
    lb/
```

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.10.0` |
| `hashicorp/google` | `>= 6.0, < 7.0` |
| `hashicorp/google-beta` | `>= 6.0, < 7.0` |
| `terraform-google-modules/network/google` | `~> 18.0` |
| `GoogleCloudPlatform/lb-internal/google` | `~> 6.0` |

The `google-beta` provider is required because the upstream network module
creates the VPC networks with it. Both providers are configured from `project`
and `region`.

## Quick start

```bash
cd terraform/gcp
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform init
terraform plan
terraform apply
```

`env/dev.tfvars` and `env/prod.tfvars` are empty placeholders; pass either one
with `-var-file` after adding environment-specific values.

The backend is declared as `backend "gcs" {}`. Supply backend configuration at
init time, for example:

```bash
terraform init \
  -backend-config="bucket=<state-bucket>" \
  -backend-config="prefix=terraform/gcp"
```

## Key inputs

| Name | Required | Description |
|------|----------|-------------|
| `project` | yes | Google Cloud project ID. |
| `region` | no | Region for VPCs, subnets, appliance MIGs, and the ILB. |
| `name_prefix` | yes | Lowercase resource name prefix. |
| `subnet_cc_service` | yes | Service subnet CIDR. |
| `subnet_mgmt` | yes | Management subnet CIDR. |
| `cc_vm_prov_url` | yes | Zscaler Cloud Connector provisioning URL. |
| `ssh_key` | yes | OpenSSH public key for `zsroot`. |
| `secret_name` | no | Secret Manager secret with provisioning material. |
| `reserved_internal_address` | no | VIP inside `subnet_cc_service`; defaults to the second-to-last usable address. |
| `zones` | no | Explicit zones for the MIGs. Overrides `az_count`. |
| `labels` | no | Caller labels; merged over the built-in defaults. |

See `variables.tf` for the full list and validation rules.

## Outputs

Network, subnet, and VIP details are exported alongside the Cloud Connector
instance group URLs, service account email, instance template ID, used zones,
and the load balancer forwarding rule. See `outputs.tf`.
