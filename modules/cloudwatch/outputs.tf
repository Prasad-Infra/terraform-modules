output "log_group_arns" { value = { for key, group in aws_cloudwatch_log_group.this : key => group.arn } }
output "alarm_arns" { value = merge({ for key, alarm in aws_cloudwatch_metric_alarm.this : key => alarm.arn }, { for key, alarm in aws_cloudwatch_composite_alarm.this : key => alarm.arn }) }
output "metric_alarm_arns" { value = { for key, alarm in aws_cloudwatch_metric_alarm.this : key => alarm.arn } }
output "composite_alarm_arns" { value = { for key, alarm in aws_cloudwatch_composite_alarm.this : key => alarm.arn } }
output "dashboard_arns" { value = { for key, dashboard in aws_cloudwatch_dashboard.this : key => dashboard.dashboard_arn } }
output "sns_topic_arns" { value = { for key, topic in aws_sns_topic.this : key => topic.arn } }
