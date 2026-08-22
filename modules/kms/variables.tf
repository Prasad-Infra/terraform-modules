variable "description" {
	type = string
}

variable "deletion_window_in_days" {
	type    = number
	default = 30
	validation {
		condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
		error_message = "deletion_window_in_days must be between 7 and 30."
	}
}

variable "enable_key_rotation" {
	type    = bool
	default = true
}

variable "alias_name" {
	description = "KMS alias name, including the alias/ prefix."
	type        = string
	validation {
		condition     = startswith(var.alias_name, "alias/") && length(var.alias_name) > 6
		error_message = "alias_name must start with alias/ and contain a name."
	}
}

variable "policy" {
	description = "Optional consumer-supplied JSON key policy."
	type        = string
	default     = null
}

variable "key_spec" {
	description = "KMS key spec, such as SYMMETRIC_DEFAULT or RSA_2048."
	type        = string
	default     = "SYMMETRIC_DEFAULT"
	validation {
		condition     = contains(["SYMMETRIC_DEFAULT", "RSA_2048", "RSA_3072", "RSA_4096", "ECC_NIST_P256", "ECC_NIST_P384", "ECC_NIST_P521", "ECC_SECG_P256K1"], var.key_spec)
		error_message = "key_spec must be a supported KMS key spec."
	}
}

variable "key_usage" {
	description = "KMS key usage configuration."
	type        = string
	default     = "ENCRYPT_DECRYPT"
	validation {
		condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"], var.key_usage)
		error_message = "key_usage must be ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC."
	}
}

variable "multi_region" {
	description = "Create a multi-Region primary KMS key."
	type        = bool
	default     = false
}

variable "bypass_policy_lockout_safety_check" {
	description = "Whether to bypass KMS policy lockout safety checks. Keep false unless explicitly required."
	type        = bool
	default     = false
}

variable "tags" {
	type    = map(string)
	default = {}
}
variable "environment" { type = string }
variable "project" { type = string }
variable "owner" { type = string }
