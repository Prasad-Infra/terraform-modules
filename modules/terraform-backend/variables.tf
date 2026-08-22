variable "bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string
  nullable    = false
  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63 && can(regex("^[a-z0-9][a-z0-9.-]+[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be a valid S3 bucket name."
  }
}

variable "enable_dynamodb_locking" {
  description = "Create a DynamoDB lock table for Terraform versions that use DynamoDB state locking."
  type        = bool
  default     = true
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name used for state locking."
  type        = string
  default     = null
  nullable    = true
}

variable "prevent_destroy" {
  description = "Prevent accidental destruction of the state bucket and lock table."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to backend resources."
  type        = map(string)
  default     = {}
}
variable "environment" { type = string }
variable "project" { type = string }
variable "owner" { type = string }
