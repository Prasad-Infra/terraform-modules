output "repository_names" {
	value = { for key, repo in aws_ecr_repository.this : key => repo.name }
}

output "repository_arns" {
	value = { for key, repo in aws_ecr_repository.this : key => repo.arn }
}

output "repository_urls" {
	value = { for key, repo in aws_ecr_repository.this : key => repo.repository_url }
}
