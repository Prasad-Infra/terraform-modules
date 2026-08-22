locals {
  common_tags = merge(var.tags, { Environment = var.environment, Project = var.project, ManagedBy = "Terraform", Owner = var.owner })
}

resource "aws_kms_key" "this" {
  description                        = var.description
  deletion_window_in_days            = var.deletion_window_in_days
  enable_key_rotation                = var.enable_key_rotation
  policy                             = var.policy
  customer_master_key_spec           = var.key_spec
  key_usage                          = var.key_usage
  multi_region                       = var.multi_region
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  tags                               = local.common_tags
}

resource "aws_kms_alias" "this" {
  name          = var.alias_name
  target_key_id = aws_kms_key.this.key_id
}
