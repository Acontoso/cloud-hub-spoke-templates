# Cloud Hub Spoke Templates

Terraform templates for building an AWS hub/inspection VPC pattern to support Zscaler Cloud Connector integration for cloud networks. **Soon to extend to other cloud platforms**.

## Overview

This repository provisions core infrastructure required for a Zscaler-integrated cloud hub network in AWS, including:

- VPC and subnet topology for inspection workloads
- Internet and NAT egress pathing
- Transit Gateway attachment and route propagation targets
- Security groups for Cloud Connector management and service interfaces
- IAM role and instance profile permissions for Cloud Connector nodes
- Gateway Load Balancer (GWLB) and target group
- GWLB endpoint service and per-subnet VPC endpoints

The current implementation is focused on foundational network and load-balancing components. It is intended to be consumed as an infrastructure template and adapted per environment.

## Repository Structure

```text
terraform/
	aws/
		main.tf
		variables.tf
		versions.tf
		env/
			terragrunt.hcl
		modules/
			appconnector/
			cloudconnector/
			gwlb/
			gwlb-endpoint/
			iam/
			sg/
			vpc/
```

## Architecture at a Glance

1. Create an inspection VPC with dedicated subnet tiers:
	 - Public subnets (NAT placement)
	 - Cloud Connector subnets
	 - Workload subnets
	 - Transit Gateway subnets
2. Attach internet and egress components:
	 - Internet Gateway
	 - One NAT Gateway per AZ (based on az_count)
3. Build route tables for each subnet tier:
	 - Default egress via NAT where required
	 - Static routes to Transit Gateway for spoke/private destinations
4. Provision security and identity controls:
	 - Cloud Connector management and service security groups
	 - IAM role + instance profile for SSM, Secrets Manager, and CloudWatch metrics
5. Deploy inspection data plane:
	 - GWLB target group and listener
	 - GWLB endpoint service
	 - Endpoint ENIs in Cloud Connector subnets

## Prerequisites

- Terraform CLI compatible with your provider lock strategy
- AWS account access and credentials with rights to create networking, IAM, and ELB resources
- Existing S3 bucket for remote state (if using Terragrunt remote_state)
- Zscaler Cloud Connector provisioning values:
	- Cloud Connector provisioning URL
	- Secrets Manager secret name for provisioning material

## Provider and Region Notes

- AWS provider is currently constrained to version `<= 6.16.0`.
- Region is currently set to `ap-southeast-2` in provider/local configuration.
- Backend block is declared as S3 and expects backend configuration at init time.

## Quick Start (Terraform)

From the repository root:

```bash
cd terraform/aws
terraform init
terraform plan
terraform apply
```

If using an S3 backend, provide backend config arguments or a backend config file during init, for example:

```bash
terraform init \
	-backend-config="bucket=<state-bucket>" \
	-backend-config="key=<path/to/state.tfstate>" \
	-backend-config="region=ap-southeast-2"
```
