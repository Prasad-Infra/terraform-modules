output "load_balancer_arn" { value = aws_lb.this.arn }
output "load_balancer_dns_name" { value = aws_lb.this.dns_name }
output "zone_id" { value = aws_lb.this.zone_id }
output "target_group_arns" { value = { for key, target_group in aws_lb_target_group.this : key => target_group.arn } }
output "listener_arns" { value = { for key, listener in aws_lb_listener.this : key => listener.arn } }
