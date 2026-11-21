# AWS inspection hub

Composable Terraform configuration for Zscaler Cloud Connector inspection and App Connector workloads. Requires Terraform 1.10 or newer (before 2.0) and AWS provider 6.16.x. Child modules accept AWS provider 6.x and inherit the caller's provider configuration.

**Status:** implementation changes only. Tests, verification, and security scanning were not performed. Provider behavior, Marketplace images, and appliance runtime compatibility remain unverified.

## Ownership and traffic flow

```text
Public subnets:    Internet Gateway <- NAT Gateway (one per AZ)
                                        ^
Private subnets:   Cloud Connectors -----+---- workload/App Connectors
                         ^
Caller-managed TGW -> attachment subnets -> zonal GWLB endpoints
                                             -> GWLB -> Cloud Connector targets
```

- [vpc](modules/vpc/README.md) owns the VPC, four subnet tiers, NAT egress, base route tables, TGW destination routes, Instance Connect endpoint, and optional flow logging.
- [sg](modules/sg/README.md) owns appliance management, service, and App Connector security groups.
- [iam](modules/iam/README.md) owns Cloud Connector identity and secret/metrics/SSM permissions.
- [cloudconnector](modules/cloudconnector/README.md) owns EC2 appliances and their forwarding/management interfaces.
- [gwlb](modules/gwlb/README.md) owns the gateway load balancer and health-checked targets.
- [gwlb-endpoint](modules/gwlb-endpoint/README.md) owns the endpoint service and ordered zonal endpoints.
- [appconnector](modules/appconnector/README.md) owns App Connector EC2 instances, a dedicated bootstrap role, and boot-time provisioning-key retrieval.
- The root owns the routes connecting TGW route tables to inspection endpoints. This keeps module dependencies acyclic.

The TGW itself, VPC attachment, TGW route tables, propagation/associations, and spoke routes are **not created**. The caller must arrange attachment appliance mode, symmetric routing, and any additional spoke configuration required by the chosen inspection design. Merely supplying a TGW ID does not connect the VPC to it.

## Configuration

Use [terraform.tfvars.example](terraform.tfvars.example) as a non-secret starting point. Required values include environment, VPC/subnet CIDRs, provisioning URL, Cloud Connector Secrets Manager secret name, and App Connector SSM SecureString parameter name. Both secrets must already exist in the deployment account and region.

- Keep each subnet list in the same AZ order and provide one subnet per tier per selected AZ.
- Pin `availability_zones` for existing environments; account-specific AZ names can represent different physical zones in different accounts.
- `cc_count` is the total count, not a per-AZ count; it must cover every selected AZ. Both connector types use round-robin placement.
- Use at least two AZs for production. A single-AZ configuration is permitted but has no zonal resilience.
- Keep `management_cidrs = []` to omit SSH ingress. A key pair alone does not authorize network access. Use narrow approved private CIDRs when SSH is required.
- Set `cc_ami_id` and `ac_ami_id` for reproducible production image selection. Null selects the latest Marketplace product image and may introduce a replacement on a later configuration refresh. Subscribe to the products in the target account/region before use.
- Images must support IMDSv2 and the chosen instance type. The App Connector image must already include AWS CLI, Bash, systemd, GNU file utilities, and the `zpa-connector` service.
- Health checks use the same `http_probe_port` in bootstrap, SG rules, and GWLB. Supported intervals are 10 or 30 seconds.
