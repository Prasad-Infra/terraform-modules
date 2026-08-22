variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
  default     = "main"
  nullable    = false
  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  nullable    = false
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability zones used by subnet tiers."
  type        = list(string)
  default     = null
  nullable    = true
  validation {
    condition     = var.availability_zones == null || (length(var.availability_zones) > 0 && length(distinct(var.availability_zones)) == length(var.availability_zones))
    error_message = "availability_zones must contain unique AZ names when specified."
  }
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, ordered like availability_zones."
  type        = list(string)
  default     = []
  validation {
    condition     = (var.availability_zones == null || length(var.public_subnet_cidrs) == 0 || length(var.public_subnet_cidrs) == length(var.availability_zones)) && alltrue([for cidr in var.public_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "public_subnet_cidrs must be empty or contain one valid CIDR per availability zone."
  }
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, ordered like availability_zones."
  type        = list(string)
  default     = []
  validation {
    condition     = (var.availability_zones == null || length(var.private_subnet_cidrs) == 0 || length(var.private_subnet_cidrs) == length(var.availability_zones)) && alltrue([for cidr in var.private_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "private_subnet_cidrs must be empty or contain one valid CIDR per availability zone."
  }
}

variable "database_subnet_cidrs" {
  description = "Database subnet CIDRs, ordered like availability_zones."
  type        = list(string)
  default     = []
  validation {
    condition     = (var.availability_zones == null || length(var.database_subnet_cidrs) == 0 || length(var.database_subnet_cidrs) == length(var.availability_zones)) && alltrue([for cidr in var.database_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "database_subnet_cidrs must be empty or contain one valid CIDR per availability zone."
  }
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}
variable "enable_dns_support" {
  type    = bool
  default = true
}
variable "enable_nat_gateway" {
  type    = bool
  default = true
}
variable "single_nat_gateway" {
  type    = bool
  default = false
}
variable "enable_flow_logs" {
  type    = bool
  default = true
}
variable "flow_log_retention_in_days" {
  type    = number
  default = 30
}
variable "flow_log_kms_key_id" {
  type    = string
  default = null
}
variable "flow_log_traffic_type" {
  type    = string
  default = "ALL"
}
variable "public_subnet_tags" {
  type    = map(string)
  default = {}
}
variable "private_subnet_tags" {
  type    = map(string)
  default = {}
}
variable "database_subnet_tags" {
  type    = map(string)
  default = {}
}
variable "eks_public_subnet_tags" {
  description = "EKS discovery tags merged into public subnets."
  type        = map(string)
  default = {
    "kubernetes.io/role/elb" = "1"
  }
}
variable "eks_private_subnet_tags" {
  description = "EKS discovery tags merged into private subnets."
  type        = map(string)
  default = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "environment" { type = string }
variable "project" { type = string }
variable "owner" { type = string }
