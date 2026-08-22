output "cluster_id" { value = aws_eks_cluster.this.id }
output "cluster_name" { value = aws_eks_cluster.this.name }
output "cluster_arn" { value = aws_eks_cluster.this.arn }
output "cluster_endpoint" { value = aws_eks_cluster.this.endpoint }
output "cluster_security_group_id" { value = try(aws_security_group.cluster[0].id, null) }
output "cluster_iam_role_arn" { value = aws_eks_cluster.this.role_arn }
output "oidc_provider_arn" { value = aws_iam_openid_connect_provider.this.arn }
output "oidc_provider_url" { value = aws_iam_openid_connect_provider.this.url }
output "node_group_ids" { value = { for key, group in aws_eks_node_group.this : key => group.id } }
output "node_group_arns" { value = { for key, group in aws_eks_node_group.this : key => group.arn } }
output "node_iam_role_arns" { value = { for key, group in var.node_groups : key => group.node_role_arn } }
output "cluster_certificate_authority" {
	value     = aws_eks_cluster.this.certificate_authority[0].data
	sensitive = true
}
