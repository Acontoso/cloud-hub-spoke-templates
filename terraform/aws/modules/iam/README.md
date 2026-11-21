# Cloud Connector identity

Creates an EC2 trust role, instance profile, and separate policies for provisioning-secret retrieval, SSM agent connectivity, and appliance metrics. Requires Terraform 1.10+ (before 2.0) and an inherited AWS provider 6.x.

## Inputs

| Input | Required / default | Purpose |
| --- | --- | --- |
| `name_prefix` | Required | 2–32 character prefix for role/profile/policy names. |
| `secret_name` | Required | Friendly name of an existing provisioning secret in this account/region. |
| `secret_kms_key_arn` | `null` | Customer-managed key ARN when the secret uses one. |
| `tags` | `{}` | IAM resource tags. |

Terraform reads secret **metadata only**, not a secret version or its value. The role receives `secretsmanager:GetSecretValue` on that single secret. An optional decrypt statement is scoped to the KMS key and the secret's encryption context; the key policy must also allow access.

SSM agent and CloudWatch discovery actions that do not support resource-level permissions use wildcard resources. CloudWatch writes are restricted to the `Zscaler/CloudConnectors` namespace. This module does not grant App Connector bootstrap access; that identity belongs to the App Connector module.

## Outputs

- `iam_instance_profile_name`: pass this to the compute module.
- `iam_instance_profile_arn`: profile ARN for integrations requiring an ARN.
- `role_arn`: role ARN for explicitly managed supplemental permissions.

Profile outputs depend on policy attachments so consumers are ordered after those attachments. This does not eliminate AWS IAM propagation delay. Compute resources also require network egress and the appropriate appliance/SSM agents.
