output "instance_ids" { value = { for key, instance in aws_instance.this : key => instance.id } }
output "private_ips" { value = { for key, instance in aws_instance.this : key => instance.private_ip } }
output "public_ips" { value = { for key, instance in aws_instance.this : key => instance.public_ip } }
output "instance_arns" { value = { for key, instance in aws_instance.this : key => instance.arn } }
output "iam_role_arn" { value = try(aws_iam_role.this[0].arn, null) }
output "security_group_id" { value = try(aws_security_group.this[0].id, null) }
output "elastic_ip_addresses" { value = { for key, eip in aws_eip.this : key => eip.public_ip } }
