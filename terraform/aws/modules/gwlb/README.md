# Gateway Load Balancer

## Requirements and ownership

Requires Terraform **>= 1.10.0** and `hashicorp/aws` **>= 6.0, < 7.0**, declared in `versions.tf`. The caller configures the provider, VPC, subnets, appliance instances and security groups.

Creates a Gateway Load Balancer, a GENEVE/6081 IP target group, ordered IP target attachments and a forwarding listener. HTTP health checks use `/?cchealth`. Deletion protection remains enabled on the GWLB.

## Inputs

| Input | Type | Default | Contract |
| --- | --- | --- | --- |
| `vpc_id` | `string` | required | Existing VPC ID for the target group. |
| `subnet_ids` | `list(string)` | required | Nonempty distinct subnet IDs, one per AZ, all in `vpc_id`. |
| `gwlb_name` | `string` | required | 1-32 alphanumeric/hyphen characters, no boundary hyphens or reserved `internal-` prefix. |
| `target_group_name` | `string` | required | 1-32 alphanumeric/hyphen characters, no boundary hyphens. |
| `cc_service_ips` | `list(string)` | required | Distinct IPv4 target addresses without CIDR suffixes; empty creates no registrations. |
| `http_probe_port` | `number` | `50000` | Integer TCP health port 1-65535; match the SG module and appliance listener. |
| `health_check_interval` | `number` | `10` | GWLB-supported 10 or 30 seconds. |
| `healthy_threshold` | `number` | `2` | Integer 2-10 consecutive successful checks. |
| `unhealthy_threshold` | `number` | `3` | Integer 2-10 consecutive failed checks. |
| `cross_zone_lb_enabled` | `bool` | `false` | Enable forwarding across AZs; additional transfer charges can apply. |
| `deregistration_delay` | `number` | `0` | Integer drain delay, 0-3600 seconds. |
| `flow_stickiness` | `string` | `"5-tuple"` | `5-tuple`, `3-tuple`, or `2-tuple`. |
| `rebalance_enabled` | `bool` | `true` | Rebalance flows for both deregistered and unhealthy targets. |
| `name_prefix` | `string` | `"inspection"` | Legacy compatibility input, validated nonnull with 1-63 alphanumeric/underscore/hyphen characters starting alphanumeric; explicit resource names control naming. |
| `tags` | `map(string)` | `{}` | Nonnull tags for GWLB and target group. |

The caller must supply actual subnets in the target-group VPC, one per AZ. Targets must be routable eligible private IPv4 addresses, with appliances and routes configured for GENEVE and the HTTP probe. With cross-zone forwarding disabled, place healthy appliance targets in every enabled AZ. The module performs input-format checks but does not discover subnet membership or appliance readiness.

## Outputs

| Output | Contract |
| --- | --- |
| `gwlb_arn` | GWLB ARN for `gwlb-endpoint.gwlb_arn`. |
| `target_group_arn` | GENEVE IP target group ARN. |
| `listener_arn` | Forwarding listener ARN. |
| `gwlb_dns_name` | AWS GWLB DNS name. |
| `gwlb_arn_suffix` | ARN suffix for CloudWatch metric dimensions. |
