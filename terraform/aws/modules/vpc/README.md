# Inspection VPC module

## Requirements and ownership

Requires Terraform **>= 1.10.0** and `hashicorp/aws` **>= 6.0, < 7.0**. Configure the AWS provider in the caller; this local module does not configure credentials or a region. `versions.tf` declares the supported versions.

Creates an IPv4 VPC with DNS hostnames, a locked-down default security group, an internet gateway, four subnet tiers, one NAT gateway/EIP per AZ, route tables/associations, and an EC2 Instance Connect endpoint in the first workload subnet. CC and workload default routes use their same-AZ NAT gateway. Public subnets share an internet-gateway route table. TGW subnet default routes are deliberately not managed here.

The caller owns the TGW, its attachment, and all GWLB-endpoint-dependent routes. Nondefault `static_routes_tgw` are installed in each CC, workload and TGW subnet route table using the explicit `transit_gateway_id`. The caller must arrange attachment readiness before those routes are created (for example, pass a TGW ID through an attachment-dependent output); this module cannot infer attachment readiness from the TGW ID alone. Never add inline routes to route tables with separately managed routes.

## Inputs

| Input | Type | Default | Contract |
| --- | --- | --- | --- |
| `vpc_cidr` | `string` | required | Canonical IPv4 VPC CIDR, /16 through /28. |
| `public_subnets` | `list(string)` | required | Exactly `az_count` canonical IPv4 /16 through /28 CIDRs for public/NAT subnets. |
| `cc_subnets` | `list(string)` | required | Exactly `az_count` canonical IPv4 /16 through /28 Cloud Connector CIDRs. |
| `workload_subnets` | `list(string)` | required | Exactly `az_count` canonical IPv4 /16 through /28 workload CIDRs. |
| `tgw_subnets` | `list(string)` | required | Exactly `az_count` canonical IPv4 /16 through /28 TGW attachment CIDRs. |
| `az_count` | `number` | `3` | Integer from 1 through 6, subject to regional AZ availability. |
| `availability_zones` | `list(string)` | `[]` | Empty uses available AZ names in AWS canonical order; otherwise exactly `az_count` distinct available names, in desired order. |
| `static_routes_tgw` | `list(string)` | `[]` | Unique canonical IPv4 CIDRs. `0.0.0.0/0` and the VPC local route are prohibited. |
| `transit_gateway_id` | `string` | `null` | Existing TGW ID; required if static routes are requested. |
| `flow_logs_enabled` | `bool` | `true` | Deliver ALL VPC flow logs to a dedicated CloudWatch log group. |
| `flow_log_retention_days` | `number` | `30` | Supported CloudWatch Logs retention period; `0` means indefinite retention. |
| `name_prefix` | `string` | `"inspection"` | Nonnull 1-63-character resource prefix, starting alphanumeric and containing only alphanumerics, `_`, `-`. |
| `tags` | `map(string)` | `{}` | Nonnull resource tags. |

Subnet CIDRs must be inside `vpc_cidr` and non-overlapping; AWS enforces both at apply time by rejecting subnet creation. CIDR position is the AZ position in every tier. Changing an explicit AZ list or the discovered AZ order can replace subnets; pin `availability_zones` for stable placement.

## Outputs and root wiring

| Output | Contract |
| --- | --- |
| `vpc_id` | Scalar VPC ID. |
| `cc_subnet_ids` | Cloud Connector IDs in input CIDR/AZ order. |
| `public_subnet_ids` | Public subnet IDs in input CIDR/AZ order. |
| `workload_subnet_ids` | Workload subnet IDs in input CIDR/AZ order. |
| `tgw_subnet_ids` | TGW attachment subnet IDs in input CIDR/AZ order. |
| `tgw_route_table_ids` | TGW route table IDs in input CIDR/AZ order. |
| `cc_route_table_ids` | Cloud Connector route table IDs in input CIDR/AZ order. |
| `workload_route_table_ids` | Workload route table IDs in input CIDR/AZ order. |
| `flow_log_group_name` | Log group name, or `null` if logging is disabled. |
| `instance_connect_security_group_id` | SG attached to the Instance Connect endpoint. |
