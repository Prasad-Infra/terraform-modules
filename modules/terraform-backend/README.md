# Terraform backend module

Bootstraps shared Terraform state storage. It creates a private, versioned, AES256-encrypted S3 bucket with a TLS-only bucket policy and, by default, a DynamoDB table for state locking.

The module does not configure a Terraform backend. Bootstrap this module from a temporary local-state root, then configure each consuming environment repository with its own root-level `backend "s3"` block using the outputs below. Do not use this module from the same state it creates.

Terraform 1.6 and earlier use DynamoDB locking. Newer Terraform versions can use S3-native locking; set `enable_dynamodb_locking = false` only after all consumers have migrated.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Bootstraps shared Terraform state storage for environment repositories.

## Features

Versioned encrypted S3 state bucket, public access blocking, TLS-only policy, optional DynamoDB locking, point-in-time recovery, and destroy protection.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`.

## Providers

`hashicorp/aws`.

## Inputs

Provide a globally unique bucket name, optional lock-table settings, destroy protection, and standard tags.

## Outputs

State bucket ID/ARN and optional lock-table name/ARN.

## Usage

```hcl
module "terraform_backend" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/terraform-backend?ref=v1.0.0"
	bucket_name = var.state_bucket_name
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

Bootstrap with temporary local state. The actual root `backend "s3"` configuration is owned by each environment repository.

## Security considerations

State is sensitive: keep bucket access least-privilege, retain versioning, preserve destroy protection, and never expose state contents in outputs or logs.
