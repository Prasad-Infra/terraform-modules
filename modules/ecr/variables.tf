variable "repositories" {
  description = "ECR repositories keyed by stable logical name. Empty objects use secure defaults."
  type = map(object({
    name                 = optional(string)
    image_tag_mutability = optional(string, "IMMUTABLE")
    scan_on_push         = optional(bool, true)
    encryption_type      = optional(string, "AES256")
    kms_key_arn          = optional(string)
    lifecycle_policy     = optional(string)
    repository_policy    = optional(string)
    force_delete         = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for repository in values(var.repositories) : contains(["MUTABLE", "IMMUTABLE"], repository.image_tag_mutability) && contains(["AES256", "KMS"], repository.encryption_type) && (repository.encryption_type == "AES256" || repository.kms_key_arn != null)
    ])
    error_message = "Repository tag mutability and encryption types must be valid; KMS encryption requires kms_key_arn."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "environment" { type = string }
variable "project" { type = string }
variable "owner" { type = string }
