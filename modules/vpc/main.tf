locals {
  common_tags = merge(var.tags, { Environment = var.environment, Project = var.project, ManagedBy = "Terraform", Owner = var.owner, Name = var.name })
  azs         = var.availability_zones == null ? slice(data.aws_availability_zones.available.names, 0, 3) : var.availability_zones
  nat_azs     = var.single_nat_gateway ? [local.azs[0]] : local.azs
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = local.common_tags
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = local.common_tags
}

resource "aws_subnet" "public" {
  for_each = { for index, cidr in var.public_subnet_cidrs : local.azs[index] => cidr }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags                    = merge(local.common_tags, var.public_subnet_tags, var.eks_public_subnet_tags, { Tier = "public" })
}

resource "aws_subnet" "private" {
  for_each = { for index, cidr in var.private_subnet_cidrs : local.azs[index] => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = merge(local.common_tags, var.private_subnet_tags, var.eks_private_subnet_tags, { Tier = "private" })
}

resource "aws_subnet" "database" {
  for_each = { for index, cidr in var.database_subnet_cidrs : local.azs[index] => cidr }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key
  tags              = merge(local.common_tags, var.database_subnet_tags, { Tier = "database" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(local.common_tags, { Tier = "public" })
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? toset(local.nat_azs) : toset([])
  domain   = "vpc"
  tags     = local.common_tags
}

resource "aws_nat_gateway" "this" {
  for_each      = aws_eip.nat
  allocation_id = each.value.id
  subnet_id     = aws_subnet.public[each.key].id
  depends_on    = [aws_internet_gateway.this]
  tags          = local.common_tags
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id   = aws_vpc.this.id
  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? local.nat_azs[0] : each.key].id
    }
  }
  tags = merge(local.common_tags, { Tier = "private" })
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table" "database" {
  for_each = aws_subnet.database
  vpc_id   = aws_vpc.this.id
  tags     = merge(local.common_tags, var.database_subnet_tags, { Tier = "database" })
}

resource "aws_route_table_association" "database" {
  for_each       = aws_subnet.database
  subnet_id      = each.value.id
  route_table_id = aws_route_table.database[each.key].id
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "/aws/vpc/${var.name}/flow-logs"
  retention_in_days = var.flow_log_retention_in_days
  kms_key_id        = var.flow_log_kms_key_id
  tags              = local.common_tags
}

resource "aws_iam_role" "flow_logs" {
  count              = var.enable_flow_logs ? 1 : 0
  name               = "${var.name}-vpc-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume[0].json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "flow_logs" {
  count  = var.enable_flow_logs ? 1 : 0
  name   = "${var.name}-vpc-flow-logs"
  role   = aws_iam_role.flow_logs[0].id
  policy = data.aws_iam_policy_document.flow_logs_write[0].json
}

resource "aws_flow_log" "this" {
  count                = var.enable_flow_logs ? 1 : 0
  iam_role_arn         = aws_iam_role.flow_logs[0].arn
  log_destination      = aws_cloudwatch_log_group.flow_logs[0].arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = var.flow_log_traffic_type
  vpc_id                   = aws_vpc.this.id
  tags                     = local.common_tags
}
