locals {
  common_tags = merge(var.tags, { Environment = var.environment, Project = var.project, ManagedBy = "Terraform", Owner = var.owner })
}

locals {
  primary_vpc_id = try(tolist(var.vpc_ids)[0], null)
  additional_vpc_ids = var.private_zone ? setsubtract(var.vpc_ids, toset([local.primary_vpc_id])) : toset([])
}

resource "aws_route53_zone" "this" {
  name = var.zone_name
  dynamic "vpc" {
    for_each = var.private_zone ? [local.primary_vpc_id] : []
    content {
      vpc_id = vpc.value
    }
  }
  tags = local.common_tags
}

resource "aws_route53_zone_association" "additional" {
  for_each = local.additional_vpc_ids
  zone_id  = aws_route53_zone.this.zone_id
  vpc_id   = each.value
}

resource "aws_route53_health_check" "this" {
  for_each                         = var.health_checks
  fqdn                             = each.value.fqdn
  ip_address                       = each.value.ip_address
  port                             = each.value.port
  type                             = each.value.type
  resource_path                    = each.value.resource_path
  failure_threshold                = each.value.failure_threshold
  request_interval                 = each.value.request_interval
  measure_latency                  = each.value.measure_latency
  invert_healthcheck               = each.value.invert_healthcheck
  disabled                         = each.value.disabled
  child_health_threshold            = each.value.child_health_threshold
  tags                             = merge(local.common_tags, { Name = each.key })
}

resource "aws_route53_record" "this" {
  for_each        = var.records
  zone_id         = aws_route53_zone.this.zone_id
  name            = coalesce(each.value.name, each.key)
  type            = each.value.type
  ttl             = each.value.alias_name == null ? each.value.ttl : null
  records         = each.value.alias_name == null ? each.value.records : null
  health_check_id = each.value.health_check_key == null ? null : aws_route53_health_check.this[each.value.health_check_key].id
  set_identifier  = each.value.routing_policy == "simple" ? null : each.value.set_identifier

  dynamic "alias" {
    for_each = each.value.alias_name == null ? [] : [each.value]
    content {
      name                   = alias.value.alias_name
      zone_id                = alias.value.alias_zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = each.value.routing_policy == "weighted" ? [each.value] : []
    content {
      weight = weighted_routing_policy.value.weight
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.routing_policy == "failover" ? [each.value] : []
    content {
      type = failover_routing_policy.value.failover_type
    }
  }

  dynamic "latency_routing_policy" {
    for_each = each.value.routing_policy == "latency" ? [each.value] : []
    content {
      region = latency_routing_policy.value.region
    }
  }
}
