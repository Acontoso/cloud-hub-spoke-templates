# VPC Module

Creates the Cloud Connector service and management VPCs using
`terraform-google-modules/network/google` v18, including subnets, Cloud Routers,
Cloud NAT gateways, and firewall rules.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `name_prefix` | `string` | yes | Lowercase prefix for all resource names. |
| `project` | `string` | yes | Google Cloud project ID. |
| `region` | `string` | no | Region for subnets, routers, and NAT. Defaults to `australia-southeast1`. |
| `subnet_cc_service` | `string` | yes | Service subnet CIDR. |
| `subnet_mgmt` | `string` | yes | Management subnet CIDR. |
| `routing_mode` | `string` | no | `REGIONAL` or `GLOBAL`. Defaults to `REGIONAL`. |

## Outputs

| Name | Description |
|------|-------------|
| `service_network_name` | Service VPC name. |
| `service_network_self_link` | Service VPC self link. |
| `service_network_id` | Service VPC ID. |
| `service_subnet_name` | Service subnet name. |
| `service_subnet_self_link` | Service subnet self link. |
| `service_subnet_id` | Service subnet ID. |
| `mgmt_network_name` | Management VPC name. |
| `mgmt_network_self_link` | Management VPC self link. |
| `mgmt_network_id` | Management VPC ID. |
| `mgmt_subnet_name` | Management subnet name. |
| `mgmt_subnet_self_link` | Management subnet self link. |
| `mgmt_subnet_id` | Management subnet ID. |

The upstream network module's `subnets` output is a map of subnet resources,
not a list of self links. This module resolves the single subnet in each VPC
and exports explicit, stable name/self-link/ID outputs so consumers do not need
to know the upstream map key format.

## Firewall behavior

- Service VPC: all egress protocols to `0.0.0.0/0` for Cloud Connector traffic.
- Management VPC: TCP `80`/`443`, UDP `123` (NTP), UDP `53` and TCP `53` (DNS),
  plus TCP `12002` to the Zscaler Support endpoint.
- Both VPCs use Cloud NAT for egress.
