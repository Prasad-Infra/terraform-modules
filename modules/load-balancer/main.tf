locals {
  common_tags = merge(var.tags, { Environment = var.environment, Project = var.project, ManagedBy = "Terraform", Owner = var.owner })
}

resource "aws_lb" "this" {
  name                       = var.name
  internal                   = var.internal
  load_balancer_type         = var.load_balancer_type
  security_groups            = var.load_balancer_type == "application" ? var.security_group_ids : null
  subnets                    = var.subnet_ids
  drop_invalid_header_fields = var.load_balancer_type == "application" ? true : null
  enable_deletion_protection = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  dynamic "access_logs" {
    for_each = var.access_logs == null ? [] : [var.access_logs]
    content {
      bucket  = access_logs.value.bucket
      enabled = access_logs.value.enabled
      prefix  = access_logs.value.prefix
    }
  }

  tags = merge(local.common_tags, { Name = var.name })
}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups
  name     = each.value.name == null ? "${var.name}-${each.key}" : each.value.name
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = var.vpc_id
  target_type = each.value.target_type

  health_check {
    enabled             = each.value.health_check.enabled
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    interval            = each.value.health_check.interval
    timeout             = each.value.health_check.timeout
    path                = each.value.health_check.path
    port                = each.value.health_check.port
    protocol            = each.value.health_check.protocol
    matcher             = each.value.health_check.matcher
  }

  tags = merge(local.common_tags, { Name = each.value.name == null ? "${var.name}-${each.key}" : each.value.name })
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for target in flatten([
      for group_key, group in var.target_groups : [
        for target_key, attachment in group.targets : {
          key         = "${group_key}/${target_key}"
          group_key   = group_key
          target_id   = attachment.target_id
          port        = attachment.port
        }
      ]
    ]) : target.key => target
  }
  target_group_arn = aws_lb_target_group.this[each.value.group_key].arn
  target_id        = each.value.target_id
  port             = each.value.port
}

resource "aws_lb_listener" "this" {
  for_each          = var.listeners
  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.protocol == "HTTPS" || each.value.protocol == "TLS" ? each.value.ssl_policy : null
  certificate_arn   = each.value.certificate_arn

  dynamic "default_action" {
    for_each = each.value.redirect_to_https ? [] : [each.value.default_target_group]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.this[default_action.value].arn
    }
  }

  dynamic "default_action" {
    for_each = each.value.redirect_to_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each     = var.listener_rules
  listener_arn = aws_lb_listener.this[each.value.listener_key].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  }

  dynamic "condition" {
    for_each = length(each.value.host_header_values) == 0 ? [] : [each.value.host_header_values]
    content {
      host_header {
        values = condition.value
      }
    }
  }

  dynamic "condition" {
    for_each = length(each.value.path_pattern_values) == 0 ? [] : [each.value.path_pattern_values]
    content {
      path_pattern {
        values = condition.value
      }
    }
  }

  dynamic "condition" {
    for_each = length(each.value.source_ip_values) == 0 ? [] : [each.value.source_ip_values]
    content {
      source_ip {
        values = condition.value
      }
    }
  }
}
