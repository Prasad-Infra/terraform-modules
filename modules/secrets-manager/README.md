# Secrets Manager module

Creates multiple named Secrets Manager secrets from non-sensitive metadata. Secret values are supplied separately through the sensitive `secret_values` map, keyed to the metadata map; values are never exposed through module outputs or documentation.

Supports customer-managed KMS keys, secret versions/stages, recovery windows, automatic rotation configuration, per-secret tags, and consumer-supplied IAM resource policies. Rotation Lambda functions and their IAM permissions remain consumer-managed.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Creates reusable Secrets Manager metadata and versions.

## Features

Multiple secrets, sensitive versions, KMS encryption, rotation, recovery windows, tags, and IAM resource policies.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`.

## Providers

`hashicorp/aws`.

## Inputs

Provide non-sensitive `secrets` metadata and the separately sensitive `secret_values` map, plus optional KMS ARNs, rotation Lambda ARNs, policies, and tags.

## Outputs

Secret ARNs, names, and IDs only. Secret values are never outputs.

## Usage

```hcl
module "secrets" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/secrets-manager?ref=v1.0.0"
	secrets = var.secret_metadata
	secret_values = var.secret_values
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

Rotation Lambda functions, KMS keys, and policy principals are consumer-managed.

## Security considerations

`secret_values` is sensitive and must come from a secure input mechanism. Never commit values, print them in CI, or place them in README examples.
