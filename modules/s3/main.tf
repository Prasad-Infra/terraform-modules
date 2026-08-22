locals {
  common_tags = merge(var.tags, { Environment = var.environment, Project = var.project, ManagedBy = "Terraform", Owner = var.owner })
}

resource "aws_s3_bucket" "this" {
  for_each      = var.buckets
  bucket        = each.value.bucket_name
  force_destroy = each.value.force_destroy
  tags          = merge(local.common_tags, { Name = each.value.bucket_name })
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each                = aws_s3_bucket.this
  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.value.id
  versioning_configuration {
    status = var.buckets[each.key].versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.value.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.buckets[each.key].encryption_type
      kms_master_key_id = var.buckets[each.key].encryption_type == "aws:kms" ? var.buckets[each.key].kms_key_arn : null
    }
    bucket_key_enabled = var.buckets[each.key].encryption_type == "aws:kms"
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.value.id
  rule {
    object_ownership = var.buckets[each.key].object_ownership
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = { for key, bucket in var.buckets : key => bucket if length(bucket.lifecycle_rules) > 0 }
  bucket   = aws_s3_bucket.this[each.key].id
  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status
      filter {
        prefix = rule.value.filter_prefix
      }
      dynamic "expiration" {
        for_each = rule.value.expiration_days == null ? [] : [rule.value.expiration_days]
        content {
          days = expiration.value
        }
      }
      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_expiration_days == null ? [] : [rule.value.noncurrent_expiration_days]
        content {
          noncurrent_days = noncurrent_version_expiration.value
        }
      }
      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
    }
  }
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  for_each = {
    for item in flatten([
      for bucket_key, bucket in var.buckets : [
        for configuration in bucket.intelligent_tiering : {
          key           = "${bucket_key}/${configuration.name}"
          bucket_key    = bucket_key
          name          = configuration.name
          prefix        = configuration.prefix
          status        = configuration.status
          tierings      = configuration.tierings
        }
      ]
    ]) : item.key => item
  }
  bucket = aws_s3_bucket.this[each.value.bucket_key].id
  name   = each.value.name
  status = each.value.status
  filter {
    prefix = each.value.prefix
  }
  dynamic "tiering" {
    for_each = each.value.tierings
    content {
      access_tier = tiering.value.access_tier
      days        = tiering.value.days
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  for_each = { for key, bucket in var.buckets : key => bucket if length(bucket.cors_rules) > 0 }
  bucket   = aws_s3_bucket.this[each.key].id
  dynamic "cors_rule" {
    for_each = each.value.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

resource "aws_s3_bucket_logging" "this" {
  for_each = { for key, bucket in var.buckets : key => bucket if bucket.access_logging != null }
  bucket   = aws_s3_bucket.this[each.key].id
  target_bucket = each.value.access_logging.bucket
  target_prefix = each.value.access_logging.prefix
}

resource "aws_s3_bucket_policy" "this" {
  for_each = { for key, bucket in var.buckets : key => bucket if bucket.bucket_policy != null }
  bucket   = aws_s3_bucket.this[each.key].id
  policy   = each.value.bucket_policy
}

resource "aws_s3_bucket_replication_configuration" "this" {
  for_each = { for key, bucket in var.buckets : key => bucket if bucket.replication != null }
  bucket   = aws_s3_bucket.this[each.key].id
  role     = each.value.replication.role_arn
  rule {
    id       = each.value.replication.rule_id
    status   = each.value.replication.status
    priority = each.value.replication.priority
    destination {
      bucket        = each.value.replication.destination_bucket_arn
      storage_class = each.value.replication.storage_class
    }
    delete_marker_replication {
      status = each.value.replication.delete_marker_replication_status
    }
  }
  depends_on = [aws_s3_bucket_versioning.this]
}
