# ACM module

Requests a public DNS-validated ACM certificate from consumer-supplied domain and SAN values. Wildcard names are accepted as normal SAN/domain inputs; no domain names are hardcoded.

Set `create_route53_validation_records = true` and provide `route53_zone_id` when the module should create DNS validation records and wait for certificate validation. Leave it false when the environment repository manages validation records itself; the module still exposes AWS validation options.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Provides reusable public ACM certificates.

## Features

DNS validation, Route 53 validation records, SANs, wildcard names, lifecycle replacement, and validation outputs.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`.

## Providers

`hashicorp/aws`.

## Inputs

Provide the certificate domain, SANs, optional Route 53 zone ID, validation-record flag, and tags. Domains are never hardcoded.

## Outputs

Certificate ARN, certificate domain, validation options, validation record FQDNs, and status.

## Usage

```hcl
module "acm" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/acm?ref=v1.0.0"
	domain_name = var.domain_name
	subject_alternative_names = var.subject_alternative_names
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

Route 53 validation records require a consumer-provided hosted zone ID when enabled.

## Security considerations

Use DNS validation and restrict access to certificate ARNs. Keep private/internal names out of public certificates unless intentionally required.
