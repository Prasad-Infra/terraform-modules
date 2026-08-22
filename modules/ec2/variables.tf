variable "instances" {
  description = "Instances to create, keyed by stable logical name."
  type = map(object({
    ami_id             = string
    instance_type      = string
    subnet_id          = string
    security_group_ids = optional(set(string), [])
    user_data          = optional(string)
    root_volume_size   = optional(number, 20)
    root_volume_type   = optional(string, "gp3")
    root_kms_key_id    = optional(string)
    additional_volumes = optional(map(object({
      device_name           = string
      volume_size           = number
      volume_type           = optional(string, "gp3")
      kms_key_id            = optional(string)
      delete_on_termination = optional(bool, true)
    })), {})
    associate_public_ip = optional(bool, false)
    elastic_ip          = optional(bool, false)
    monitoring          = optional(bool, true)
  }))
  default = {}
}

variable "name_prefix" {
  description = "Name prefix for instances and optional shared resources."
  type        = string
}

variable "create_iam_role" {
  type    = bool
  default = true
}

variable "iam_role_name" {
  type    = string
  default = null
}

variable "instance_profile_name" {
  type    = string
  default = null
}

variable "enable_ssm" {
  type    = bool
  default = true
}

variable "create_security_group" {
  type    = bool
  default = false
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "security_group_name" {
  type    = string
  default = null
}

variable "ingress_rules" {
  type = map(object({
    cidr_ipv4   = string
    from_port   = number
    to_port     = number
    protocol    = string
    description = optional(string)
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
