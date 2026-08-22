locals {
  common_tags = merge(var.tags, { Environment = var.environment, Project = var.project, ManagedBy = "Terraform", Owner = var.owner })
}

resource "aws_cloudwatch_log_group" "this" {
  for_each          = var.log_groups
  name              = each.value.name
  retention_in_days = each.value.retention_in_days
  kms_key_id        = each.value.kms_key_id
  log_group_class   = each.value.log_group_class
  tags              = merge(local.common_tags, each.value.tags, { Name = each.value.name })
}

resource "aws_sns_topic" "this" {
  for_each          = var.sns_topics
  name              = each.value.name
  display_name      = each.value.display_name
  kms_master_key_id = each.value.kms_master_key_id
  tags              = merge(local.common_tags, each.value.tags, { Name = each.value.name })
}

resource "aws_cloudwatch_metric_alarm" "this" {
  for_each                  = var.alarms
  alarm_name                = each.value.alarm_name
  alarm_description         = each.value.alarm_description
  actions_enabled           = each.value.actions_enabled
  alarm_actions             = concat(each.value.alarm_actions, [for key in each.value.alarm_topic_keys : aws_sns_topic.this[key].arn])
  ok_actions                = each.value.ok_actions
  insufficient_data_actions = each.value.insufficient_data_actions
  comparison_operator       = each.value.comparison_operator
  evaluation_periods        = each.value.evaluation_periods
  metric_name               = each.value.metric_name
  namespace                 = each.value.namespace
  period                    = each.value.period
  statistic                 = each.value.statistic
  threshold                 = each.value.threshold
  treat_missing_data        = each.value.treat_missing_data
  dimensions                = each.value.dimensions
  tags                      = local.common_tags
}

resource "aws_cloudwatch_composite_alarm" "this" {
  for_each                  = var.composite_alarms
  alarm_name                = each.value.alarm_name
  alarm_rule                = each.value.alarm_rule
  alarm_description         = each.value.alarm_description
  actions_enabled           = each.value.actions_enabled
  alarm_actions             = concat(each.value.alarm_actions, [for key in each.value.alarm_topic_keys : aws_sns_topic.this[key].arn])
  ok_actions                = each.value.ok_actions
  insufficient_data_actions = each.value.insufficient_data_actions
  tags                      = local.common_tags
}

resource "aws_cloudwatch_dashboard" "this" {
  for_each       = var.dashboards
  dashboard_name = each.value.name
  dashboard_body = each.value.body
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each       = var.metric_filters
  name           = each.value.name
  log_group_name = aws_cloudwatch_log_group.this[each.value.log_group_key].name
  pattern        = each.value.pattern

  metric_transformation {
    name          = each.value.metric_name
    namespace     = each.value.namespace
    value         = each.value.metric_value
    default_value = each.value.default_value
    dimensions    = each.value.dimensions
    unit          = each.value.unit
  }
}
