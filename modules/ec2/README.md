# EC2 module

Creates multiple keyed EC2 instances using one launch template per instance. The AMI ID, instance type, subnet, and optional existing security groups are supplied by the consumer; no AMI IDs are hardcoded.

The module enables encrypted GP3 root volumes, optional additional encrypted EBS volumes, IMDSv2, detailed monitoring, user data, and optional Elastic IPs. `monitoring` is configured per instance.

By default, the module creates an IAM role, instance profile, and SSM Session Manager attachment. Set `create_iam_role = false` and provide `instance_profile_name` to use an existing profile. Set `create_security_group = true` and provide `vpc_id` to create the module-managed security group; otherwise provide security group IDs per instance.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Creates reusable launch-template-backed EC2 capacity.

## Features

Multiple instances, IAM/profile, SSM, optional security groups and EIPs, encrypted root/additional EBS, user data, IMDSv2, and detailed monitoring.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`. AMI IDs and network IDs are consumer inputs.

## Providers

`hashicorp/aws`.

## Inputs

Use the keyed `instances` map for AMI, type, subnet, volumes, user data, monitoring, and EIP settings; provide `name_prefix`, tag inputs, and existing or managed IAM/security-group settings.

## Outputs

Instance IDs, private/public IPs, instance ARNs, IAM role ARN, security group ID, and EIP addresses.

## Usage

```hcl
module "ec2" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/ec2?ref=v1.0.0"
	name_prefix = var.name_prefix
	instances = var.instances
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

None internally. Consumers provide AMIs, subnets, and optional existing security groups or profiles.

## Security considerations

IMDSv2, encrypted EBS, SSM support, and monitoring are enabled by default. Review user data and ingress rules because they can contain operational access.
