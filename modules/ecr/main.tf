locals {
  common_tags = merge(var.tags, { Environment = var.environment, Project = var.project, ManagedBy = "Terraform", Owner = var.owner })
}

resource "aws_ecr_repository" "this" {
  for_each             = var.repositories
  name                 = coalesce(each.value.name, each.key)
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = each.value.encryption_type
    kms_key         = each.value.encryption_type == "KMS" ? each.value.kms_key_arn : null
  }

  tags = merge(local.common_tags, { Name = coalesce(each.value.name, each.key) })
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = { for key, repository in var.repositories : key => repository if repository.lifecycle_policy != null }
  repository = aws_ecr_repository.this[each.key].name
  policy     = each.value.lifecycle_policy
}

resource "aws_ecr_repository_policy" "this" {
  for_each   = { for key, repository in var.repositories : key => repository if repository.repository_policy != null }
  repository = aws_ecr_repository.this[each.key].name
  policy     = each.value.repository_policy
}
