# KMS module

Creates a customer-managed KMS key with rotation enabled by default, a consumer-supplied JSON key policy, configurable key spec and usage, optional multi-Region support, and a consumer-defined alias. The deletion window is configurable from 7 to 30 days.

Keep `bypass_policy_lockout_safety_check` false unless the consumer has explicitly reviewed the supplied policy. Key policies and aliases are not generated with account, region, or principal values by this module.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Creates reusable customer-managed KMS keys.

## Features

Consumer key policies, rotation, aliases, multi-Region keys, configurable key specs/usages, and deletion windows.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`.

## Providers

`hashicorp/aws`.

## Inputs

Provide key description, alias, policy JSON, usage/spec, multi-Region flag, deletion window, rotation, and standard tags.

## Outputs

Key ID, key ARN, alias ARN, and alias name.

## Usage

```hcl
module "kms" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/kms?ref=v1.0.0"
	description = var.key_description
	alias_name = var.key_alias
	policy = var.key_policy
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

None internally. The consumer owns policy principals and cross-module key consumers.

## Security considerations

Rotation is enabled by default and the deletion window is bounded. Review key policies carefully and keep policy lockout bypass disabled.
