variable "domain_name" {
	description = "Consumer-provided certificate domain, including wildcard domains when required."
	type        = string
}

variable "subject_alternative_names" {
	type    = set(string)
	default = []
}

variable "validation_method" {
	type    = string
	default = "DNS"
	validation {
		condition     = var.validation_method == "DNS"
		error_message = "Only DNS validation is supported."
	}
}

variable "route53_zone_id" {
	description = "Route 53 hosted zone ID for DNS validation records."
	type        = string
	default     = null
}

variable "create_route53_validation_records" {
	description = "Create Route 53 DNS validation records and wait for certificate validation."
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
