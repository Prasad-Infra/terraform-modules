# Route 53 module

Creates a public or private hosted zone with consumer-supplied domain names. Private zones can be associated with multiple VPC IDs. Records are map-driven and support A, AAAA, CNAME, alias, weighted, failover, and latency routing policies.

Health checks are created from a separate map and referenced by record key. Routing records must provide a unique `set_identifier`; simple records do not require one. Alias records use the target name and hosted-zone ID supplied by the consumer.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Provides reusable public and private Route 53 DNS management.

## Features

Hosted zones, multiple VPC associations, A/AAAA/CNAME/alias records, weighted/failover/latency routing, and health checks.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`.

## Providers

`hashicorp/aws`.

## Inputs

Provide `zone_name`, optional private-zone `vpc_ids`, map-driven `records` and `health_checks`, and standard tags.

## Outputs

Hosted zone ID, ARN, name, name servers, record FQDNs, and health-check IDs.

## Usage

```hcl
module "dns" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/route53?ref=v1.0.0"
	zone_name = var.zone_name
	private_zone = var.private_zone
	vpc_ids = var.vpc_ids
	records = var.records
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

Private zones depend on consumer-provided VPC IDs. Alias targets and health-check values are consumer-managed.

## Security considerations

Keep private zones associated only with intended VPCs and restrict health-check endpoints. Do not publish sensitive internal names in public zones.
