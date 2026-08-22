# Load balancer module

Creates an internal or internet-facing Application or Network Load Balancer from consumer-supplied subnets. Target groups, target attachments, listeners, listener rules, health checks, TLS certificates, and optional access logs are all keyed and configurable.

Use `protocol = "HTTPS"` with `certificate_arn` for TLS termination. Set `redirect_to_https = true` on an HTTP listener to create an HTTP-to-HTTPS redirect. Listener rules support host-header, path-pattern, and source-IP conditions.

Security groups are applied only to Application Load Balancers. Network Load Balancers use the supplied subnets and target-group protocol settings.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Provides reusable ALB/NLB traffic distribution.

## Features

Internal or internet-facing load balancers, target groups, health checks, target attachments, HTTP/HTTPS/TLS listeners, redirects, routing rules, certificates, and access logs.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`.

## Providers

`hashicorp/aws`.

## Inputs

Provide `vpc_id`, `subnet_ids`, `target_groups`, `listeners`, `listener_rules`, optional security groups/certificate ARNs, access logs, and standard tags.

## Outputs

Load balancer ARN/DNS/zone ID, target group ARNs, and listener ARNs.

## Usage

```hcl
module "load_balancer" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/load-balancer?ref=v1.0.0"
	name = var.load_balancer_name
	vpc_id = var.vpc_id
	subnet_ids = var.subnet_ids
	target_groups = var.target_groups
	listeners = var.listeners
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

None internally. Networking, security groups, target IDs, and ACM certificates are consumer inputs.

## Security considerations

Use HTTPS/TLS listeners and consumer-managed certificates for encrypted transit. Keep security groups and listener rules least-privilege.
