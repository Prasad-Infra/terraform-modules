variable "vpc_id" {
  type = string
}

variable "name_prefix" {
  description = "Name prefix for an optional endpoint security group."
  type        = string
  default     = "main"
}

variable "service_name_prefix" {
  description = "Optional full endpoint service prefix; defaults to com.amazonaws.<provider-region>."
  type        = string
  default     = null
}

variable "gateway_endpoints" {
  description = "Gateway endpoints such as s3 and dynamodb, keyed by logical name."
  type = map(object({
    service         = string
    route_table_ids = set(string)
    policy          = optional(string)
  }))
  default = {}
}

variable "interface_endpoints" {
  description = "Interface endpoints such as ecr.api, ssm, and secretsmanager, keyed by logical name."
  type = map(object({
    service             = string
    subnet_ids          = set(string)
    security_group_ids  = optional(set(string), [])
    private_dns_enabled = optional(bool, true)
    policy              = optional(string)
  }))
  default = {}
}

variable "create_security_group" {
  description = "Create a shared security group for interface endpoints."
  type        = bool
  default     = false
}

variable "security_group_name" {
  type    = string
  default = null
}

variable "security_group_ingress_cidr_blocks" {
  description = "CIDRs permitted to connect to interface endpoints on TCP/443."
  type        = set(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "environment" { type = string }
variable "project" { type = string }
variable "owner" { type = string }
