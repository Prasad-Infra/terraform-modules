# VPC endpoints module

Creates consumer-selected Gateway and Interface VPC endpoints. Gateway endpoints receive their own route-table sets and are suitable for `s3` and `dynamodb`. Interface endpoints receive subnet sets, optional security groups, private DNS, and optional policies; service names such as `ecr.api`, `ecr.dkr`, `ssm`, `ssmmessages`, `ec2messages`, `logs`, `secretsmanager`, `kms`, `sts`, and `monitoring` are supported through the configurable map.

Short service names are automatically prefixed with `com.amazonaws.<configured-provider-region>`. Full service names can also be supplied. The optional module-managed endpoint security group permits TCP/443 only from caller-supplied CIDRs.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Provides private AWS service connectivity from a VPC.

## Features

S3/DynamoDB Gateway endpoints, configurable Interface endpoints, private DNS, endpoint policies, subnet selection, and optional TCP/443 security groups.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`.

## Providers

`hashicorp/aws`.

## Inputs

Provide `vpc_id`, `gateway_endpoints`, `interface_endpoints`, optional endpoint security-group settings, and common tags.

## Outputs

Endpoint IDs, ARNs, DNS entries, and the optional endpoint security group ID.

## Usage

```hcl
module "vpc_endpoints" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/vpc-endpoints?ref=v1.0.0"
	vpc_id = var.vpc_id
	gateway_endpoints = var.gateway_endpoints
	interface_endpoints = var.interface_endpoints
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

The consumer supplies VPC route tables, subnets, and any existing security groups.

## Security considerations

Private DNS is enabled by default for Interface endpoints. Supply narrow endpoint policies and ingress CIDRs; do not expose endpoint services broadly.
