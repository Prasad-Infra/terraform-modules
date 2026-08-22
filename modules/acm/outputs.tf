output "certificate_arn" { value = aws_acm_certificate.this.arn }
output "certificate_domain" { value = aws_acm_certificate.this.domain_name }
output "domain_validation_options" { value = aws_acm_certificate.this.domain_validation_options }
output "validation_record_fqdns" { value = [for record in aws_route53_record.validation : record.fqdn] }
output "status" { value = aws_acm_certificate.this.status }
