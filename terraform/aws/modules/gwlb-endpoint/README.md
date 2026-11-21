# Gateway Load Balancer endpoint service and endpoints

## Requirements and ownership

Requires Terraform **>= 1.10.0** and `hashicorp/aws` **>= 6.0, < 7.0**, declared in `versions.tf`. The caller configures the provider and supplies an existing GWLB, VPC and subnets. The service uses the provider's current region through the AWS provider 6 resource-level `region` argument.

Creates an IPv4 endpoint service backed by the GWLB and one explicitly typed `GatewayLoadBalancer` endpoint per supplied subnet. It creates no routes, TGW attachments, GWLBs, or appliance instances. Acceptance is disabled; allowed principals therefore form the authorization boundary for establishing connections.

## Inputs

| Input | Type | Default | Contract |
| --- | --- | --- | --- |
| `aws_cc_subnet_ids` | `list(string)` | required | Nonempty ordered list of distinct endpoint subnet IDs, one per AZ, all in `vpc_id`. |
| `vpc_id` | `string` | required | VPC ID containing the endpoint subnets. |
| `gwlb_arn` | `string` | required | Gateway Load Balancer ARN containing `loadbalancer/gwy/`. |
| `allowed_principals` | `list(string)` | `[]` | Empty defaults to this AWS account's root principal. Otherwise distinct explicit IAM root/role/user ARNs without wildcards. |
| `name_prefix` | `string` | `"inspection"` | Nonnull 1-63-character resource prefix, starting alphanumeric and containing only alphanumerics, `_`, `-`. |
| `tags` | `map(string)` | `{}` | Nonnull endpoint service and endpoint tags. |

The caller must align the endpoint subnet AZs with the GWLB's enabled AZs and route tables. Subnet ID format and uniqueness are checked; real membership/AZ compatibility is enforced by AWS. Keep the caller's account authorized if overriding principals while also creating local endpoints. Explicitly adding another account grants it connection authority without manual acceptance and should be a deliberate trust decision. No public wildcard principal is accepted.

## Outputs and routing contract

| Output | Contract |
| --- | --- |
| `endpoint_ids` | `list(string)` ordered exactly like `aws_cc_subnet_ids`. |
| `service_name` | Published GWLB endpoint service name. |
| `service_id` | Endpoint service ID. |

Pass the GWLB module's `gwlb_arn` here. Keep `aws_cc_subnet_ids` in the VPC module's AZ order. The caller can then route each `tgw_route_table_ids[index]` default to `endpoint_ids[index]`. Endpoints are not route-table-associated gateway endpoints: GWLB endpoints require caller-managed route entries. Lists with matching length but different AZ order are not interchangeable.

## Costs and migration

GWLB endpoints incur per-AZ hourly and data-processing charges, separately from GWLB, NAT gateways and appliances. The module creates an endpoint for every supplied subnet; removing or disabling a route does not stop endpoint hourly charges.

- Upgrade Terraform and the AWS provider; provider 6 is required for the explicit service region argument. Region lookup now uses the nondeprecated `region` attribute.
- Account scope now uses the caller identity's explicit `account_id`; it defaults only to that account, never `*`.
- Endpoint type is explicitly `GatewayLoadBalancer`, not inferred from the endpoint service's computed type.
- Existing resource names/addresses and the `aws_cc_subnet_ids` input name are retained. The previously empty outputs now expose ordered `endpoint_ids`, `service_name`, and `service_id`.
- Endpoint instances remain count-based. Reordering subnet IDs can replace endpoints and disrupt dependent routes; preserve subnet/AZ ordering during migration.
- The formerly null prefix now defaults to `inspection`; preserve the previous explicit prefix if retaining naming is important.
- Transfer any old VPC-module endpoint default-route state into the caller's new route addresses before changing ownership. This endpoint module does not manage those route resources.

No tests, formatting, initialization, validation, plans, scanners, or post-change checks were run for this modernization.
