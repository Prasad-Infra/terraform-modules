variable "zone_name" {
  description = "Consumer-provided hosted-zone domain name."
  type        = string
}

variable "private_zone" {
  type    = bool
  default = false
}

variable "vpc_ids" {
  description = "VPC IDs associated with a private hosted zone."
  type        = set(string)
  default     = []
}

variable "health_checks" {
  description = "Health checks keyed by stable logical name."
  type = map(object({
    fqdn                      = optional(string)
    ip_address                = optional(string)
    port                      = optional(number, 443)
    type                      = optional(string, "HTTPS")
    resource_path             = optional(string, "/")
    failure_threshold         = optional(number, 3)
    request_interval          = optional(number, 30)
    measure_latency           = optional(bool, true)
    invert_healthcheck        = optional(bool, false)
    disabled                  = optional(bool, false)
    child_health_threshold    = optional(number)
  }))
  default = {}
  validation {
    condition = alltrue([
      for record in values(var.records) : contains(["A", "AAAA", "CNAME"], record.type) && contains(["simple", "weighted", "failover", "latency"], record.routing_policy)
    ])
    error_message = "Records must use type A, AAAA, or CNAME and a supported routing policy."
  }
}

variable "records" {
  description = "DNS records keyed by stable logical name."
  type = map(object({
    name                   = optional(string)
    type                   = string
    ttl                    = optional(number, 300)
    records                = optional(list(string), [])
    alias_name             = optional(string)
    alias_zone_id          = optional(string)
    evaluate_target_health = optional(bool, false)
    health_check_key       = optional(string)
    routing_policy         = optional(string, "simple")
    set_identifier         = optional(string)
    weight                 = optional(number)
    failover_type          = optional(string)
    region                 = optional(string)
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
