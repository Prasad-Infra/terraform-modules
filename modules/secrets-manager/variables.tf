variable "secrets" {
  description = "Non-sensitive secret metadata keyed by stable logical name."
  type = map(object({
    name                    = optional(string)
    description             = optional(string)
    kms_key_arn             = optional(string)
    recovery_window_in_days = optional(number, 30)
    version_stages          = optional(set(string), ["AWSCURRENT"])
    tags                    = optional(map(string), {})
    resource_policy         = optional(string)
    rotation = optional(object({
      rotation_lambda_arn     = string
      automatically_after_days = optional(number, 30)
      duration                = optional(string)
      rotate_immediately      = optional(bool, true)
    }))
  }))
  default = {}
}

variable "secret_values" {
  description = "Secret values keyed by the corresponding secrets map key. Supply securely; values are never output."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "environment" { type = string }
variable "project" { type = string }
variable "owner" { type = string }
