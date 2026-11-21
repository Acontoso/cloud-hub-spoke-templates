# Cloud Connector compute

Creates standalone Marketplace EC2 appliances with separate service and management ENIs. The service interface disables source/destination checks for forwarding. This is not an autoscaling module and does not guarantee rolling replacement capacity.

Requires Terraform 1.10+ (before 2.0) and an inherited AWS provider 6.x. The caller owns networking, routing, security groups, IAM, and Marketplace subscriptions.

## Inputs

| Input | Required / default | Purpose |
| --- | --- | --- |
| `name_prefix` | Required | 2–32 character resource-name prefix. |
| `aws_cc_subnet_ids` | Required | Ordered non-empty unique subnet list. |
| `service_interface_sg_id` | Required | Forwarding ENI security group. |
| `management_interface_sg_id` | Required | Management ENI security group. |
| `iam_instance_profile_name` | Required | Existing profile **name**, not ARN. |
| `userdata` | Required | Raw vendor bootstrap content, not base64; do not embed secret values. |
| `cc_count` | `3` | Total appliance count, round-robin over subnets. |
| `ccvm_instance_type` | `m6i.large` | Vendor-supported type matching the provisioning template. |
| `ami_id` | `null` | Explicit regional AMI; null selects the latest matching Marketplace product. |
| `instance_key` | `null` | Optional EC2 key-pair name. |
| `ebs_encryption_enabled` | `true` | Root-volume encryption. |
| `kms_key_arn` | `null` | Optional customer-managed EBS key; requires encryption. |
| `ebs_volume_type` | `gp3` | `gp2` or `gp3`. |
| `tags` | `{}` | Additional resource tags. |

## Outputs

- `forwarding_ip`: ordered service ENI private addresses for GWLB targets.
- `management_ips`: ordered management ENI private addresses.
- `instance_ids`: ordered instance IDs.
