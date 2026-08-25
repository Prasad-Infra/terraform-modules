output "endpoint_ids" {
  value = merge(
    { for key, endpoint in aws_vpc_endpoint.gateway : key => endpoint.id },
    { for key, endpoint in aws_vpc_endpoint.interface : key => endpoint.id }
  )
}

output "endpoint_arns" {
  value = merge(
    { for key, endpoint in aws_vpc_endpoint.gateway : key => endpoint.arn },
    { for key, endpoint in aws_vpc_endpoint.interface : key => endpoint.arn }
  )
}

output "endpoint_dns_entries" {
  value = merge(
    { for key, endpoint in aws_vpc_endpoint.gateway : key => endpoint.dns_entry },
    { for key, endpoint in aws_vpc_endpoint.interface : key => endpoint.dns_entry }
  )
}

output "endpoint_security_group_id" {
  value = try(aws_security_group.endpoint[0].id, null)
}
