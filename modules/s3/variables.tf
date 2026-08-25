variable "buckets" {
  description = "Buckets keyed by logical name. Names are supplied by consumers."
  type = map(object({
    bucket_name      = string
    versioning       = optional(bool, true)
    force_destroy    = optional(bool, false)
    encryption_type  = optional(string, "AES256")
    kms_key_arn      = optional(string)
    object_ownership = optional(string, "BucketOwnerEnforced")
    bucket_policy    = optional(string)
    lifecycle_rules = optional(list(object({
      id                         = string
      status                     = optional(string, "Enabled")
      filter_prefix              = optional(string)
      expiration_days            = optional(number)
      noncurrent_expiration_days = optional(number)
      transitions = optional(list(object({
        days          = number
        storage_class = string
      })), [])
    })), [])
    intelligent_tiering = optional(list(object({
      name     = string
      prefix   = optional(string)
      status   = optional(string, "Enabled")
      tierings = list(object({ days = number, access_tier = string }))
    })), [])
    cors_rules = optional(list(object({
      allowed_headers = optional(list(string), [])
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = optional(list(string), [])
      max_age_seconds = optional(number, 3000)
    })), [])
    access_logging = optional(object({
      bucket = string
      prefix = optional(string, "")
    }))
    replication = optional(object({
      role_arn                         = string
      destination_bucket_arn           = string
      rule_id                          = optional(string, "replicate-all")
      status                           = optional(string, "Enabled")
      priority                         = optional(number, 1)
      storage_class                    = optional(string, "STANDARD")
      delete_marker_replication_status = optional(string, "Disabled")
    }))
  }))
  default = {}
  validation {
    condition = alltrue([
      for bucket in values(var.buckets) : contains(["AES256", "aws:kms"], bucket.encryption_type) && (bucket.encryption_type == "AES256" || bucket.kms_key_arn != null)
    ])
    error_message = "encryption_type must be AES256 or aws:kms; aws:kms requires kms_key_arn."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "environment" { type = string }
variable "project" { type = string }
variable "owner" { type = string }
