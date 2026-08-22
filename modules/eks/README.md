# EKS module

Creates a production-oriented EKS control plane and multiple managed node groups such as `system`, `application`, and `spot`. The environment supplies the cluster/node IAM roles, VPC subnets, optional KMS key, Kubernetes version, and capacity settings.

The module supports managed cluster and node security groups, private/public API endpoints, control-plane logging, secrets encryption, OIDC, IRSA roles, EKS access entries, Pod Identity associations, and managed add-ons including CoreDNS, kube-proxy, VPC CNI, and EBS CSI. Node groups use launch templates with encrypted GP3 disks, labels, taints, user data, and IMDS-compatible EKS defaults.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Provides reusable Amazon EKS control planes and managed worker capacity.

## Features

Managed node groups, launch templates, encrypted disks, security groups, OIDC/IRSA, access entries, control-plane logging, KMS secrets encryption, add-ons, and Pod Identity.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`; TLS provider `>= 4.0`.

## Providers

`hashicorp/aws`, `hashicorp/tls`.

## Inputs

Provide cluster/node IAM roles, VPC/subnet IDs, optional KMS key, Kubernetes version, endpoint settings, and map-driven node groups, add-ons, access entries, IRSA roles, and Pod Identity associations.

## Outputs

Cluster name, ARN, endpoint, security group ID, IAM role ARN, OIDC ARN/URL, node group IDs/ARNs, and node IAM role ARNs.

## Usage

```hcl
module "eks" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/eks?ref=v1.0.0"
	cluster_name = var.cluster_name
	vpc_id = var.vpc_id
	subnet_ids = var.subnet_ids
	role_arn = var.cluster_role_arn
	node_groups = var.node_groups
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

The consumer supplies VPC/subnets, IAM roles, and optional KMS keys. Kubernetes provider configuration belongs outside this module.

## Security considerations

Private API access, control-plane logs, KMS secrets encryption, encrypted node disks, and security groups should be reviewed for each environment. Keep public API CIDRs narrow.
