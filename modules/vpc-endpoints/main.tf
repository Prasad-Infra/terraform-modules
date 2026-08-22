locals {
  common_tags         = merge(var.tags, { Environment = var.environment, Project = var.project, ManagedBy = "Terraform", Owner = var.owner })
  service_name_prefix = coalesce(var.service_name_prefix, "com.amazonaws.${data.aws_region.current.name}")
  interface_sg_ids = {
    for key, endpoint in var.interface_endpoints : key => setunion(
      endpoint.security_group_ids,
      var.create_security_group ? toset([aws_security_group.endpoint[0].id]) : toset([])
    )
  }
}

resource "aws_security_group" "endpoint" {
  count       = var.create_security_group ? 1 : 0
  name        = coalesce(var.security_group_name, "${var.name_prefix}-vpc-endpoints")
  description = "Security group for interface VPC endpoints"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { Name = coalesce(var.security_group_name, "${var.name_prefix}-vpc-endpoints") })
}

resource "aws_vpc_security_group_ingress_rule" "endpoint" {
  for_each          = var.create_security_group ? var.security_group_ingress_cidr_blocks : toset([])
  security_group_id = aws_security_group.endpoint[0].id
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "HTTPS access to interface endpoints"
}

resource "aws_vpc_security_group_egress_rule" "endpoint" {
  count             = var.create_security_group ? 1 : 0
  security_group_id = aws_security_group.endpoint[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_endpoint" "gateway" {
  for_each          = var.gateway_endpoints
  vpc_id            = var.vpc_id
  service_name      = startswith(each.value.service, "com.amazonaws.") ? each.value.service : "${local.service_name_prefix}.${each.value.service}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = each.value.route_table_ids
  policy            = each.value.policy
  tags              = merge(local.common_tags, { Name = each.key })
}

resource "aws_vpc_endpoint" "interface" {
  for_each           = var.interface_endpoints
  vpc_id             = var.vpc_id
  service_name       = startswith(each.value.service, "com.amazonaws.") ? each.value.service : "${local.service_name_prefix}.${each.value.service}"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = each.value.subnet_ids
  security_group_ids = local.interface_sg_ids[each.key]
  private_dns_enabled = each.value.private_dns_enabled
  policy              = each.value.policy
  tags                = merge(local.common_tags, { Name = each.key })
}
