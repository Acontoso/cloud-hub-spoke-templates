# Appliance security groups

## Requirements and ownership

Requires Terraform **>= 1.10.0** and `hashicorp/aws` **>= 6.0, < 7.0**, declared in `versions.tf`. The caller configures the provider and attaches the resulting security groups to appliance interfaces. This module does not create a VPC or any network interfaces.

Creates management, service and App Connector groups. Management SSH is disabled by default and enabled only for explicitly supplied IPv4 networks. No hardcoded developer SSH source remains, and no IPv6 outbound rule is created.

## Inputs

| Input | Type | Default | Contract |
| --- | --- | --- | --- |
| `vpc_id` | `string` | required | VPC ID for all three groups. |
| `vpc_cidr` | `string` | required | Canonical IPv4 /16 through /28 CIDR of that VPC, not its ID. Used by service health, HTTPS cluster, and GENEVE rules. |
| `management_cidrs` | `list(string)` | `[]` | Distinct canonical IPv4 SSH source CIDRs; empty means no SSH ingress. `0.0.0.0/0` is prohibited. |
| `http_probe_port` | `number` | required | Integer TCP port 1-65535, matching the GWLB HTTP probe and appliance listener. |
| `zssupport_server` | `string` | `"199.168.148.101/32"` | Canonical IPv4 remote-support destination CIDR other than `0.0.0.0/0`; replace for noncommercial clouds as needed. |
| `name_prefix` | `string` | `"inspection"` | Nonnull 1-63-character resource prefix, starting alphanumeric and containing only alphanumerics, `_`, `-`. |
| `tags` | `map(string)` | `{}` | Nonnull tags for groups. |

The caller is responsible for ensuring that `vpc_cidr` actually belongs to `vpc_id`. Management CIDRs should be trusted operator/bastion networks, not broad workload networks. Because Instance Connect preserves no client IP in the VPC module, its traffic originates from its endpoint network interface; allow an appropriate internal CIDR explicitly if this access path is needed. No source-security-group SSH rule is inferred.

## Outputs

| Output | Contract |
| --- | --- |
| `service_security_group_id` | Cloud Connector service-interface SG ID. |
| `mgmt_security_group_id` | Cloud Connector management-interface SG ID. |
| `app_connector_security_group_id` | App Connector interface SG ID. |
