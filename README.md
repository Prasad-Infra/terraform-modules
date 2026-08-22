# terraform-env-modules

Reusable, production-grade AWS Terraform modules. This repository contains reusable modules and repository automation only. Environment repositories own provider configuration, state backends, composition, and environment-specific values.

## Module catalog

| Module | Scope |
| --- | --- |
| `vpc` | VPC, three-AZ-capable subnet tiers, routing, NAT, DNS, EKS tags, and flow logs |
| `ec2` | Launch-template-backed instances, encrypted EBS, IAM/SSM, IMDSv2, monitoring, and EIPs |
| `s3` | Private encrypted buckets, versioning, lifecycle, CORS, logging, and replication |
| `load-balancer` | ALB/NLB, target groups, listeners, TLS, redirects, routing rules, and access logs |
| `vpc-endpoints` | Gateway and interface endpoints with private DNS, policies, and endpoint security groups |
| `route53` | Public/private zones, VPC associations, records, routing policies, and health checks |
| `ecr` | Multiple encrypted repositories, scanning, tag mutability, and image policies |
| `secrets-manager` | Secret metadata, sensitive versions, KMS, rotation, recovery, and resource policies |
| `cloudwatch` | Log groups, metric filters, alarms, composites, dashboards, and SNS topics |
| `eks` | EKS control plane, managed nodes, security groups, OIDC/IRSA, access, add-ons, and Pod Identity |
| `kms` | Customer-managed keys, policies, rotation, aliases, usage, and multi-Region settings |
| `acm` | Public DNS-validated certificates, SANs, wildcards, and optional Route 53 validation |
| `terraform-backend` | Bootstrap-only state S3 storage and optional DynamoDB locking |

## Design contract

Modules require Terraform `>= 1.6.0` and AWS provider `>= 5.0`. The EKS module also requires the TLS provider for OIDC discovery.

Consumers provide AWS provider configuration, account and region selection, resource names, VPC/subnet CIDRs, subnet IDs, IAM roles, KMS ARNs, certificates, policies, and notification destinations. Modules do not contain credentials, account IDs, regions, environment names, AMI IDs, domains, backend blocks, or `.tfvars` files.

Security defaults include blocked S3 public access, encryption, immutable ECR tags, ECR scan-on-push, IMDSv2, encrypted EBS volumes, private EKS endpoints, VPC Flow Logs, KMS rotation, and protected Terraform state storage. Public routes and AWS-required egress paths are limited to the networking resources that need them; review every plan and supply least-privilege policies and ingress CIDRs.

## Tagging standard

Every module requires `environment`, `project`, and `owner` inputs and applies these common tags to managed resources:

```hcl
tags = {
	Environment = var.environment
	Project     = var.project
	ManagedBy   = "Terraform"
	Owner       = var.owner
}
```

Additional custom tags are accepted through the module `tags` input. Environment repositories provide the values; this repository does not hardcode environment names.

## Module composition

Modules are intentionally independent and do not call other modules internally. The consuming environment repository composes them and passes resource identifiers between them:

| Consumer input | Typical producer |
| --- | --- |
| `vpc_id`, `subnet_ids` | `vpc` |
| `security_group_ids` | Environment repository or security-group resources |
| `kms_key_arn` / `encryption_key_arn` | `kms` |
| `certificate_arn` | `acm` |
| `route_table_ids` | `vpc` |
| Endpoint, ECR, DNS, secret, alarm, and dashboard ARNs | Corresponding module outputs |

The `vpc`, `kms`, and `terraform-backend` modules create their own directly-owned resources only. The EKS, load-balancer, S3, Secrets Manager, VPC endpoints, and other service modules consume caller-provided networking, encryption, identity, certificate, policy, and notification inputs rather than creating those modules internally.

## Remote state

Use `terraform-backend` once from a temporary bootstrap root using local state. It creates the shared state bucket and optional lock table. Configure the actual `backend "s3"` block only in each environment repository; do not use the backend module from the same state it creates.

## Quality and release checks

```shell
terraform fmt -check -recursive
terraform init -backend=false   # run inside each module
terraform validate              # run inside each module
tflint --recursive
checkov -d . --framework terraform
trivy config .
```

Pull requests run formatting, per-module credential-free validation, Terraform documentation generation, TFLint, Checkov, and Trivy configuration scanning. The documentation workflow regenerates each module README and fails if generated content is not committed. Semantic-version tags matching `vMAJOR.MINOR.PATCH` create GitHub releases.

## Versioning

Modules are released from Git tags using Semantic Versioning: `MAJOR.MINOR.PATCH`. Tags use a `v` prefix, for example `v1.0.0`. A tag push creates a corresponding GitHub release through `.github/workflows/release.yml`.

Environment repositories consume immutable module refs:

```hcl
module "vpc" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/vpc?ref=v1.0.0"
}
```

Environment-specific inputs remain in the consuming repository. This repository contains no environment-specific release configuration.

## Contributing

Keep changes inside the owning module unless a repository-wide change is necessary. Add or update module inputs, outputs, README documentation, and security controls together. Do not add environment directories, provider/backend configuration, credentials, secrets, `.tfvars` files, or hardcoded account, region, domain, AMI, or environment values.

Before opening a pull request, run formatting, initialize each module with `-backend=false`, validate each module, and run TFLint, Checkov, and Trivy. Use focused commits and describe any breaking input/output changes. Releases are created only from reviewed SemVer Git tags.
