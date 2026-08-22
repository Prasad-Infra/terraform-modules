output "bucket_ids" {
	value = { for key, bucket in aws_s3_bucket.this : key => bucket.id }
}

output "bucket_arns" {
	value = { for key, bucket in aws_s3_bucket.this : key => bucket.arn }
}

output "bucket_domain_names" {
	value = { for key, bucket in aws_s3_bucket.this : key => bucket.bucket_domain_name }
}

output "bucket_regional_domain_names" {
	value = { for key, bucket in aws_s3_bucket.this : key => bucket.bucket_regional_domain_name }
}
