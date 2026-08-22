output "state_bucket_id" {
  description = "S3 bucket name used by the Terraform backend."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "S3 bucket ARN used by the Terraform backend."
  value       = aws_s3_bucket.state.arn
}

output "lock_table_name" {
  description = "DynamoDB lock table name, or null when locking is disabled."
  value       = try(aws_dynamodb_table.lock[0].name, null)
}

output "lock_table_arn" {
  description = "DynamoDB lock table ARN, or null when locking is disabled."
  value       = try(aws_dynamodb_table.lock[0].arn, null)
}
