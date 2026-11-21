# Cloud Hub Spoke Templates

Composable AWS and Google Cloud infrastructure templates for Zscaler Cloud Connector networking and inspection. AWS also includes App Connector compute and provisioning.

## Deployment guides

- [AWS inspection hub](terraform/aws/README.md): VPC/subnet tiers, per-AZ NAT, security groups, appliance IAM, Cloud/App Connector EC2, GWLB, and inspection endpoints.
- [Google Cloud hub](terraform/gcp/README.md): service/management networks, NAT, zonal managed appliance groups, and an internal load balancer with a shared bootstrap VIP.

Each cloud directory contains local reusable modules, operator documentation, and a non-secret example input file. Provider configuration and backend selection belong to the deployment roots; child modules inherit providers and expose explicit contracts.

These templates are starting points for an organization-specific deployment, not a complete enterprise landing zone. Remote-state protection, cloud access, vendor subscriptions/licensing, upstream/spoke connectivity, and appliance operations remain the operator's responsibility. The AWS Transit Gateway and its attachment are externally managed.
