locals {
  common_tags = merge(var.tags, { Environment = var.environment, Project = var.project, ManagedBy = "Terraform", Owner = var.owner })
  cluster_security_group_ids = setunion(
    var.security_group_ids,
    var.create_cluster_security_group ? toset([aws_security_group.cluster[0].id]) : toset([])
  )
  node_security_group_ids = setunion(
    var.node_security_group_ids,
    var.create_node_security_group ? toset([aws_security_group.node[0].id]) : toset([])
  )
  oidc_issuer_host = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}

resource "aws_security_group" "cluster" {
  count       = var.create_cluster_security_group ? 1 : 0
  name        = "${var.cluster_name}-cluster"
  description = "EKS cluster control-plane security group"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { Name = "${var.cluster_name}-cluster" })
}

resource "aws_security_group" "node" {
  count       = var.create_node_security_group ? 1 : 0
  name        = "${var.cluster_name}-nodes"
  description = "EKS managed node security group"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { Name = "${var.cluster_name}-nodes" })
}

resource "aws_vpc_security_group_ingress_rule" "node_from_cluster" {
  count                        = var.create_node_security_group && var.create_cluster_security_group ? 1 : 0
  security_group_id            = aws_security_group.node[0].id
  referenced_security_group_id = aws_security_group.cluster[0].id
  ip_protocol                  = "-1"
  description                  = "Cluster control plane to worker nodes"
}

resource "aws_vpc_security_group_ingress_rule" "node_self" {
  count                        = var.create_node_security_group ? 1 : 0
  security_group_id            = aws_security_group.node[0].id
  referenced_security_group_id = aws_security_group.node[0].id
  ip_protocol                  = "-1"
  description                  = "Worker node to worker node traffic"
}

resource "aws_vpc_security_group_egress_rule" "cluster" {
  count             = var.create_cluster_security_group ? 1 : 0
  security_group_id = aws_security_group.cluster[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "node" {
  count             = var.create_node_security_group ? 1 : 0
  security_group_id = aws_security_group.node[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_eks_cluster" "this" {
  name                          = var.cluster_name
  role_arn                      = var.role_arn
  version                       = var.kubernetes_version
  bootstrap_self_managed_addons = false
  enabled_cluster_log_types     = var.enabled_cluster_log_types
  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = local.cluster_security_group_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }
  dynamic "encryption_config" {
    for_each = var.encryption_key_arn == null ? [] : [var.encryption_key_arn]
    content {
      provider {
        key_arn = encryption_config.value
      }
      resources = ["secrets"]
    }
  }
  tags = local.common_tags
}

data "tls_certificate" "oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
  tags            = local.common_tags
}

resource "aws_eks_node_group" "this" {
  for_each        = var.node_groups
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = each.value.node_role_arn
  subnet_ids      = each.value.subnet_ids
  instance_types  = each.value.instance_types
  capacity_type   = each.value.capacity_type
  ami_type        = each.value.ami_type
  launch_template {
    id      = aws_launch_template.node[each.key].id
    version = aws_launch_template.node[each.key].latest_version
  }
  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }
  update_config {
    max_unavailable = each.value.max_unavailable
  }
  labels = each.value.labels
  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
  tags = merge(local.common_tags, { Name = "${var.cluster_name}-${each.key}" })
}

resource "aws_launch_template" "node" {
  for_each               = var.node_groups
  name                   = "${var.cluster_name}-${each.key}"
  vpc_security_group_ids = local.node_security_group_ids
  user_data              = each.value.user_data == null ? null : base64encode(each.value.user_data)
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = each.value.disk_size
      volume_type           = each.value.disk_type
      encrypted             = true
      kms_key_id            = each.value.disk_kms_key_arn
      delete_on_termination = true
    }
  }
  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.common_tags, { Name = "${var.cluster_name}-${each.key}" })
  }
  tag_specifications {
    resource_type = "volume"
    tags          = merge(local.common_tags, { Name = "${var.cluster_name}-${each.key}" })
  }
}

resource "aws_eks_addon" "this" {
  for_each                    = var.addons
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.value.name
  addon_version               = each.value.addon_version
  service_account_role_arn    = each.value.service_account_role_arn
  resolve_conflicts_on_create = each.value.resolve_conflicts_on_create
  resolve_conflicts_on_update = each.value.resolve_conflicts_on_update
  tags                        = local.common_tags
}

resource "aws_eks_access_entry" "this" {
  for_each      = var.access_entries
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value.principal_arn
  type          = each.value.type
  user_name     = each.value.user_name
  kubernetes_groups = each.value.kubernetes_groups
}

resource "aws_iam_role" "irsa" {
  for_each           = var.irsa_roles
  name               = each.value.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.this.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.oidc_issuer_host}:sub" = "system:serviceaccount:${each.value.namespace}:${each.value.service_account}"
          "${local.oidc_issuer_host}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
  tags               = merge(local.common_tags, { Name = each.value.role_name })
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each   = { for item in flatten([for key, role in var.irsa_roles : [for policy_arn in role.policy_arns : { key = "${key}/${policy_arn}", role = key, policy_arn = policy_arn }]]) : item.key => item }
  role       = aws_iam_role.irsa[each.value.role].name
  policy_arn = each.value.policy_arn
}

resource "aws_eks_pod_identity_association" "this" {
  for_each        = var.pod_identity_associations
  cluster_name    = aws_eks_cluster.this.name
  namespace       = each.value.namespace
  service_account = each.value.service_account
  role_arn        = each.value.role_arn
}
