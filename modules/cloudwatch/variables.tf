variable "log_groups" {
	type = map(object({
		name              = string
		retention_in_days = optional(number, 30)
		kms_key_id        = optional(string)
		log_group_class   = optional(string, "STANDARD")
		tags              = optional(map(string), {})
	}))
	default = {}
}

variable "alarms" {
	type = map(object({
		alarm_name                = string
		alarm_description         = optional(string)
		actions_enabled           = optional(bool, true)
		alarm_actions             = optional(list(string), [])
		alarm_topic_keys          = optional(set(string), [])
		ok_actions                = optional(list(string), [])
		insufficient_data_actions = optional(list(string), [])
		metric_name               = string
		namespace                 = string
		threshold                 = number
		comparison_operator       = optional(string, "GreaterThanOrEqualToThreshold")
		evaluation_periods        = optional(number, 1)
		period                    = optional(number, 300)
		statistic                 = optional(string, "Average")
		treat_missing_data        = optional(string, "notBreaching")
		dimensions                = optional(map(string), {})
	}))
	default = {}
}

variable "composite_alarms" {
	type = map(object({
		alarm_name                = string
		alarm_rule                = string
		alarm_description         = optional(string)
		actions_enabled           = optional(bool, true)
		alarm_actions             = optional(list(string), [])
		alarm_topic_keys          = optional(set(string), [])
		ok_actions                = optional(list(string), [])
		insufficient_data_actions = optional(list(string), [])
	}))
	default = {}
}

variable "dashboards" {
	type = map(object({
		name = string
		body = string
	}))
	default = {}
}

variable "metric_filters" {
	type = map(object({
		name           = string
		log_group_key  = string
		pattern        = string
		metric_name    = string
		namespace      = string
		metric_value   = string
		default_value  = optional(number)
		dimensions     = optional(map(string), {})
		unit           = optional(string)
	}))
	default = {}
}

variable "sns_topics" {
	type = map(object({
		name              = string
		display_name      = optional(string)
		kms_master_key_id = optional(string)
		tags              = optional(map(string), {})
	}))
	default = {}
}

variable "tags" {
	type    = map(string)
	default = {}
}
variable "environment" { type = string }
variable "project" { type = string }
variable "owner" { type = string }
