output "vpc_id" { value = aws_vpc.this.id }
output "vpc_arn" { value = aws_vpc.this.arn }
output "vpc_cidr" { value = aws_vpc.this.cidr_block }
output "public_subnet_ids" { value = [for subnet in aws_subnet.public : subnet.id] }
output "private_subnet_ids" { value = [for subnet in aws_subnet.private : subnet.id] }
output "database_subnet_ids" { value = [for subnet in aws_subnet.database : subnet.id] }
output "public_route_table_id" { value = aws_route_table.public.id }
output "private_route_table_ids" { value = { for az, table in aws_route_table.private : az => table.id } }
output "database_route_table_ids" { value = { for az, table in aws_route_table.database : az => table.id } }
output "route_table_ids" { value = merge({ public = aws_route_table.public.id }, { for az, table in aws_route_table.private : "private-${az}" => table.id }, { for az, table in aws_route_table.database : "database-${az}" => table.id }) }
output "nat_gateway_ids" { value = [for gateway in aws_nat_gateway.this : gateway.id] }
output "internet_gateway_id" { value = aws_internet_gateway.this.id }
output "flow_log_group_name" { value = try(aws_cloudwatch_log_group.flow_logs[0].name, null) }
