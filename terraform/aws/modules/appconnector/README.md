# App Connector compute and bootstrap

Creates private standalone EC2 App Connectors and a dedicated least-privilege bootstrap role. The provisioning key is retrieved from SSM at instance boot, not interpolated into Terraform configuration, user data, or state by this module.

Requires Terraform 1.10+ (before 2.0), an inherited AWS provider 6.x, existing workload networking/security groups, a Marketplace subscription, and a same-account/same-region SSM SecureString parameter.

## Inputs

| Input | Required / default | Purpose |
| --- | --- | --- |
| `name_prefix` | Required | 2–32 character naming prefix. |
| `aws_workload_subnet_ids` | Required | Ordered non-empty unique workload subnet list. |
| `app_connector_sg_id` | Required | Instance security group. |
| `provisioning_parameter_name` | Required | SSM parameter name/path; not its value or ARN. |
| `provisioning_kms_key_arn` | `null` | Optional customer-managed key used by the SecureString. |
| `ac_count` | `2` | Total instance count, placed round-robin across subnets. |
| `acvm_instance_type` | `t3.medium` | Marketplace-supported x86 instance type. |
| `ami_id` | `null` | Explicit regional AMI; null discovers the latest product image. |
| `app_instance_key` | `null` | Optional existing EC2 key-pair name. |
| `ebs_kms_key_arn` | `null` | Optional EBS key; null uses the account default. |
| `tags` | `{}` | Resource tags. |

## Outputs

- `instance_ids`: ordered instance IDs.
- `private_ips`: ordered private IPv4 addresses.
- `role_arn`: dedicated App Connector role ARN.
