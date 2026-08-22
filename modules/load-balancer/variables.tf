variable "name" {
	type = string
}

variable "vpc_id" {
	type = string
}

variable "subnet_ids" {
	type = set(string)
	validation {
		condition     = length(var.subnet_ids) >= 2
		error_message = "At least two subnets are required."
	}
}

variable "security_group_ids" {
	description = "Security groups for an Application Load Balancer."
	type        = set(string)
	default     = []
}

variable "load_balancer_type" {
	type    = string
	default = "application"
	validation {
		condition     = contains(["application", "network"], var.load_balancer_type)
		error_message = "load_balancer_type must be application or network."
	}
}

variable "internal" {
	type    = bool
	default = false
}

variable "enable_deletion_protection" {
	type    = bool
	default = true
}

variable "enable_cross_zone_load_balancing" {
	type    = bool
	default = true
}

variable "target_groups" {
	description = "Target groups keyed by stable logical name."
	type = map(object({
		name        = optional(string)
		port        = number
		protocol    = string
		target_type = optional(string, "instance")
		health_check = optional(object({
			enabled             = optional(bool, true)
			healthy_threshold   = optional(number, 3)
			unhealthy_threshold = optional(number, 3)
			interval            = optional(number, 30)
			timeout             = optional(number, 5)
			path                = optional(string, "/")
			port                = optional(string, "traffic-port")
			protocol            = optional(string, "HTTP")
			matcher             = optional(string, "200-399")
		}), {})
		targets = optional(map(object({
			target_id = string
			port      = optional(number)
		})), {})
	}))
	default = {}
}

variable "listeners" {
	description = "Listeners keyed by stable logical name."
	type = map(object({
		port                 = number
		protocol             = string
		ssl_policy           = optional(string)
		certificate_arn      = optional(string)
		default_target_group = optional(string)
		redirect_to_https    = optional(bool, false)
	}))
	default = {}
}

variable "listener_rules" {
	description = "Host, path, and source-IP listener rules keyed by stable logical name."
	type = map(object({
		listener_key       = string
		target_group_key   = string
		priority           = number
		host_header_values = optional(list(string), [])
		path_pattern_values = optional(list(string), [])
		source_ip_values   = optional(list(string), [])
	}))
	default = {}
}

variable "access_logs" {
	description = "Optional load balancer access logs destination."
	type = object({
		bucket  = string
		prefix  = optional(string)
		enabled = optional(bool, true)
	})
	default = null
}

variable "tags" {
	type    = map(string)
	default = {}
}
variable "environment" { type = string }
variable "project" { type = string }
variable "owner" { type = string }
