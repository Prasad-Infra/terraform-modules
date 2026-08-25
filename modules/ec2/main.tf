locals {
  common_tags           = merge(var.tags, { Environment = var.environment, Project = var.project, ManagedBy = "Terraform", Owner = var.owner })
  role_name             = coalesce(var.iam_role_name, "${var.name_prefix}-ec2")
  instance_profile      = var.create_iam_role ? aws_iam_instance_profile.this[0].name : var.instance_profile_name
  managed_security_ids  = var.create_security_group ? toset([aws_security_group.this[0].id]) : toset([])
  instance_security_ids = { for key, instance in var.instances : key => setunion(instance.security_group_ids, local.managed_security_ids) }
}

resource "aws_iam_role" "this" {
  count              = var.create_iam_role ? 1 : 0
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = merge(local.common_tags, { Name = local.role_name })
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_role ? 1 : 0
  name  = "${local.role_name}-profile"
  role  = aws_iam_role.this[0].name
  tags  = merge(local.common_tags, { Name = "${local.role_name}-profile" })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.create_iam_role && var.enable_ssm ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "this" {
  count       = var.create_security_group ? 1 : 0
  name        = var.security_group_name != null ? var.security_group_name : "${var.name_prefix}-ec2"
  description = "Security group managed by the EC2 module"
  vpc_id      = var.vpc_id
  tags        = merge(local.common_tags, { Name = var.security_group_name != null ? var.security_group_name : "${var.name_prefix}-ec2" })
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each          = var.create_security_group ? var.ingress_rules : {}
  security_group_id = aws_security_group.this[0].id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  description       = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "this" {
  count             = var.create_security_group ? 1 : 0
  security_group_id = aws_security_group.this[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_launch_template" "this" {
  for_each               = var.instances
  name                   = "${var.name_prefix}-${each.key}"
  image_id               = each.value.ami_id
  instance_type          = each.value.instance_type
  user_data              = each.value.user_data == null ? null : base64encode(each.value.user_data)
  vpc_security_group_ids = local.instance_security_ids[each.key]

  iam_instance_profile { name = local.instance_profile }
  monitoring { enabled = each.value.monitoring }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted             = true
      volume_size           = each.value.root_volume_size
      volume_type           = each.value.root_volume_type
      kms_key_id            = each.value.root_kms_key_id
      delete_on_termination = true
    }
  }

  dynamic "block_device_mappings" {
    for_each = each.value.additional_volumes
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        encrypted             = true
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = block_device_mappings.value.volume_type
        kms_key_id            = block_device_mappings.value.kms_key_id
        delete_on_termination = block_device_mappings.value.delete_on_termination
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.common_tags, { Name = "${var.name_prefix}-${each.key}" })
  }
  tag_specifications {
    resource_type = "volume"
    tags          = merge(local.common_tags, { Name = "${var.name_prefix}-${each.key}" })
  }
}

resource "aws_instance" "this" {
  for_each                    = var.instances
  subnet_id                   = each.value.subnet_id
  associate_public_ip_address = each.value.associate_public_ip
  launch_template {
    id      = aws_launch_template.this[each.key].id
    version = aws_launch_template.this[each.key].latest_version
  }
  tags = merge(local.common_tags, { Name = "${var.name_prefix}-${each.key}" })
}

resource "aws_eip" "this" {
  for_each = { for key, instance in var.instances : key => instance if instance.elastic_ip }
  domain   = "vpc"
  tags     = merge(local.common_tags, { Name = "${var.name_prefix}-${each.key}" })
}

resource "aws_eip_association" "this" {
  for_each      = aws_eip.this
  allocation_id = each.value.id
  instance_id   = aws_instance.this[each.key].id
}
