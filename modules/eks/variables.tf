variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  description = "Optional Kubernetes version; when null, AWS selects the provider default."
  type        = string
  default     = null
}

variable "role_arn" {
  description = "IAM role ARN for the EKS control plane."
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = set(string)
}

variable "security_group_ids" {
  description = "Additional cluster security groups supplied by the consumer."
  type        = set(string)
  default     = []
}

variable "node_security_group_ids" {
  description = "Additional node security groups supplied by the consumer."
  type        = set(string)
  default     = []
}

variable "create_cluster_security_group" {
  type    = bool
  default = true
}

variable "create_node_security_group" {
  type    = bool
  default = true
}

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "endpoint_public_access" {
  type    = bool
  default = false
}

variable "public_access_cidrs" {
  type    = list(string)
  default = []
}

variable "enabled_cluster_log_types" {
  description = "EKS control-plane log types to enable."
  type        = set(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "node_groups" {
  description = "Managed node groups keyed by stable logical name, such as system, application, or spot."
  type = map(object({
    node_role_arn    = string
    subnet_ids       = set(string)
    instance_types   = optional(set(string), ["t3.medium"])
    desired_size     = optional(number, 2)
    min_size         = optional(number, 1)
    max_size         = optional(number, 4)
    capacity_type    = optional(string, "ON_DEMAND")
    ami_type         = optional(string, "AL2_x86_64")
    disk_size        = optional(number, 50)
    disk_type        = optional(string, "gp3")
    disk_kms_key_arn = optional(string)
    user_data        = optional(string)
    labels           = optional(map(string), {})
    taints = optional(set(object({
      key    = string
      value  = optional(string)
      effect = string
    })), [])
    max_unavailable = optional(number, 1)
  }))
  default = {}
}

variable "encryption_key_arn" {
  description = "Optional KMS key ARN for EKS secrets encryption."
  type        = string
  default     = null
}

variable "addons" {
  description = "EKS add-ons, including coredns, kube-proxy, vpc-cni, and aws-ebs-csi-driver."
  type = map(object({
    name                        = string
    addon_version               = optional(string)
    service_account_role_arn    = optional(string)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "PRESERVE")
  }))
  default = {
    coredns    = { name = "coredns" }
    kube_proxy = { name = "kube-proxy" }
    vpc_cni    = { name = "vpc-cni" }
    ebs_csi    = { name = "aws-ebs-csi-driver" }
  }
}

variable "access_entries" {
  type = map(object({
    principal_arn     = string
    type              = optional(string, "STANDARD")
    user_name         = optional(string)
    kubernetes_groups = optional(set(string), [])
  }))
  default = {}
}

variable "irsa_roles" {
  description = "IAM roles trusted by specific Kubernetes service accounts."
  type = map(object({
    role_name       = string
    namespace       = string
    service_account = string
    policy_arns     = set(string)
  }))
  default = {}
}

variable "pod_identity_associations" {
  type = map(object({
    namespace       = string
    service_account = string
    role_arn        = string
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
