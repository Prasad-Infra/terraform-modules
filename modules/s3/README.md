# S3 module

Creates private S3 buckets with public access blocked, ownership controls, versioning, and server-side encryption enabled by default. Consumers can select SSE-S3 (`AES256`) or SSE-KMS (`aws:kms`) with a supplied KMS key ARN.

Lifecycle rules support expiration, noncurrent-version expiration, and storage-class transitions. Optional intelligent-tiering configurations, CORS rules, access logging, custom bucket policies, and cross-region replication are supported per bucket.

Replication requires consumer-managed IAM permissions and a destination bucket. Versioning must remain enabled on both replication buckets.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Creates secure reusable S3 storage.

## Features

Versioning, SSE-S3/SSE-KMS, public access blocking, ownership controls, lifecycle rules, Intelligent-Tiering, CORS, logging, policies, and replication.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`.

## Providers

`hashicorp/aws`.

## Inputs

Use the keyed `buckets` map for bucket names, encryption, policies, lifecycle, CORS, logging, and replication; provide KMS ARNs and custom tags as needed.

## Outputs

Bucket IDs, ARNs, standard domain names, and regional domain names.

## Usage

```hcl
module "s3" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/s3?ref=v1.0.0"
	buckets = var.buckets
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

None internally. KMS keys and replication IAM roles remain consumer-managed.

## Security considerations

Public access is blocked and encryption is enabled by default. Never place credentials or secret values in bucket policies, lifecycle configuration, or documentation.
