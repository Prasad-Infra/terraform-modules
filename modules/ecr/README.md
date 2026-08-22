# ECR module

Creates multiple ECR repositories from a keyed map. An empty object such as `frontend = {}` uses immutable tags, scan-on-push, and AES256 encryption by default. Each repository can override its name, tag mutability, encryption type/KMS ARN, force-delete behavior, lifecycle policy, and repository policy.

Use `encryption_type = "KMS"` with a consumer-supplied `kms_key_arn` for customer-managed encryption. Lifecycle and repository policies are accepted as JSON strings and are not exposed through module outputs.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Creates reusable container image repositories.

## Features

Multiple repositories, scan-on-push, immutable/mutable tags, AES256/KMS encryption, lifecycle policies, repository policies, and optional force deletion.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`.

## Providers

`hashicorp/aws`.

## Inputs

Provide the keyed `repositories` map. Empty entries use secure defaults; override KMS ARNs, lifecycle/repository policy JSON, mutability, and force deletion per repository.

## Outputs

Repository names, ARNs, and URLs.

## Usage

```hcl
module "ecr" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/ecr?ref=v1.0.0"
	repositories = var.repositories
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

None internally. KMS keys and repository policy principals are consumer-managed.

## Security considerations

Scan-on-push, immutable tags, and encryption are enabled by default. Keep force deletion disabled for production repositories and review policy principals.
