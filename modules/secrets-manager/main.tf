locals {
  common_tags = merge(var.tags, { Environment = var.environment, Project = var.project, ManagedBy = "Terraform", Owner = var.owner })
}

resource "aws_secretsmanager_secret" "this" {
  for_each                = var.secrets
  name                    = coalesce(each.value.name, each.key)
  description             = each.value.description
  kms_key_id              = each.value.kms_key_arn
  recovery_window_in_days = each.value.recovery_window_in_days
  tags                    = merge(local.common_tags, each.value.tags, { Name = coalesce(each.value.name, each.key) })
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each       = nonsensitive(toset(keys(var.secret_values)))
  secret_id      = aws_secretsmanager_secret.this[each.key].id
  secret_string  = var.secret_values[each.key]
  version_stages = var.secrets[each.key].version_stages
}

resource "aws_secretsmanager_secret_rotation" "this" {
  for_each            = { for key, secret in var.secrets : key => secret if secret.rotation != null }
  secret_id           = aws_secretsmanager_secret.this[each.key].id
  rotation_lambda_arn = each.value.rotation.rotation_lambda_arn
  rotate_immediately  = each.value.rotation.rotate_immediately

  rotation_rules {
    automatically_after_days = each.value.rotation.automatically_after_days
    duration                 = each.value.rotation.duration
  }
}

resource "aws_secretsmanager_secret_policy" "this" {
  for_each   = { for key, secret in var.secrets : key => secret if secret.resource_policy != null }
  secret_arn = aws_secretsmanager_secret.this[each.key].arn
  policy     = each.value.resource_policy
}
