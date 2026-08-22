output "zone_id" { value = aws_route53_zone.this.zone_id }
output "zone_arn" { value = aws_route53_zone.this.arn }
output "zone_name" { value = aws_route53_zone.this.name }
output "name_servers" { value = aws_route53_zone.this.name_servers }
output "record_fqdns" { value = { for key, record in aws_route53_record.this : key => record.fqdn } }
output "health_check_ids" { value = { for key, check in aws_route53_health_check.this : key => check.id } }
