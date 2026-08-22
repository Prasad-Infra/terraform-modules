# VPC module

Creates an environment-agnostic VPC with configurable DNS settings, public, private application, and database subnet tiers, route tables and associations, an internet gateway, and either one NAT gateway or one NAT gateway per availability zone. CIDRs, AZs, names, and common tags are supplied by the consumer.

When `enable_flow_logs` is true, the module also creates a CloudWatch log group, IAM role, least-privilege write policy, and VPC flow log. Set `flow_log_retention_in_days` and optionally provide a KMS key ID.

Public, private, and database subnet tag maps are independently configurable. EKS discovery tags default to `kubernetes.io/role/elb=1` for public subnets and `kubernetes.io/role/internal-elb=1` for private subnets.

## Three-AZ topology

When `availability_zones` is omitted, the module automatically selects the first three available AZs from the configured AWS provider region. The consuming environment must still provide exactly three values in each enabled subnet CIDR list, using the same index for the corresponding AZ and subnet CIDR. It may also pass an explicit three-item `availability_zones` list:

```hcl
availability_zones      = var.availability_zones_3
public_subnet_cidrs     = var.public_subnet_cidrs_3
private_subnet_cidrs    = var.private_subnet_cidrs_3
database_subnet_cidrs   = var.database_subnet_cidrs_3
enable_nat_gateway      = true
single_nat_gateway      = false
```

With `single_nat_gateway = false`, the module creates one NAT gateway and EIP in each of the three public subnets. Set it to `true` to create one shared NAT gateway in the first AZ.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Provides reusable VPC networking for consumer-managed AWS environments.

## Features

VPC, IGW, public/private/database subnets, route tables, NAT gateways, DNS settings, EKS tags, and optional CloudWatch Flow Logs.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`. The consumer supplies provider configuration, CIDRs, and tags.

## Providers

`hashicorp/aws`.

## Inputs

Use `vpc_cidr`, `availability_zones`, the three subnet CIDR lists, NAT/flow-log/DNS flags, subnet tag maps, and common tag inputs.

## Outputs

VPC ID/ARN/CIDR, subnet IDs, route table IDs, NAT Gateway IDs, Internet Gateway ID, and flow-log group name.

## Usage

```hcl
module "vpc" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/vpc?ref=v1.0.0"
	name   = var.vpc_name
	vpc_cidr = var.vpc_cidr
	availability_zones = var.availability_zones
	public_subnet_cidrs = var.public_subnet_cidrs
	private_subnet_cidrs = var.private_subnet_cidrs
	database_subnet_cidrs = var.database_subnet_cidrs
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

None internally; IAM/KMS inputs for Flow Logs are managed by this module when enabled.

## Security considerations

DNS support, encrypted log groups when a KMS key is supplied, and Flow Logs are enabled by default. Consumer-provided CIDRs and tags must be reviewed.
