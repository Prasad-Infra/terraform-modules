locals {
  common_tags = merge(var.tags, { Environment = var.environment, Project = var.project, ManagedBy = "Terraform", Owner = var.owner })
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method
  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}

resource "aws_route53_record" "validation" {
  for_each = var.create_route53_validation_records ? {
    for option in aws_acm_certificate.this.domain_validation_options : option.domain_name => option
  } : {}

  allow_overwrite = true
  name            = each.value.resource_record_name
  records         = [each.value.resource_record_value]
  ttl             = 60
  type            = each.value.resource_record_type
  zone_id         = var.route53_zone_id
}

resource "aws_acm_certificate_validation" "this" {
  count                   = var.create_route53_validation_records ? 1 : 0
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
