resource "aws_security_group" "ec2" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "Security group for the EC2 host used by the Docker Compose deployment"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  count = var.enable_public_ssh && var.allowed_ssh_cidr != null ? 1 : 0

  security_group_id = aws_security_group.ec2.id
  description       = "Restricted break-glass SSH"
  cidr_ipv4         = var.allowed_ssh_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_security_group" "alb" {
  count       = var.enable_alb ? 1 : 0
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for the public Munch Catering ALB"
  vpc_id      = var.vpc_id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each = var.enable_alb ? {
    for pair in setproduct(var.alb_ingress_ports, var.alb_ingress_cidrs) : "${pair[0]}-${pair[1]}" => {
      port = pair[0]
      cidr = pair[1]
    }
  } : {}
  security_group_id = aws_security_group.alb[0].id
  description       = "Public ALB listener on port ${each.value.port}"
  cidr_ipv4         = each.value.cidr
  from_port         = each.value.port
  ip_protocol       = "tcp"
  to_port           = each.value.port
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  count             = var.enable_alb ? 1 : 0
  security_group_id = aws_security_group.alb[0].id
  description       = "ALB egress to application targets"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "ec2_from_alb" {
  count                        = var.enable_alb ? 1 : 0
  security_group_id            = aws_security_group.ec2.id
  referenced_security_group_id = aws_security_group.alb[0].id
  description                  = "Application traffic from the ALB only"
  from_port                    = var.target_port
  ip_protocol                  = "tcp"
  to_port                      = var.target_port
}

resource "aws_vpc_security_group_ingress_rule" "app" {
  for_each = var.open_app_ports ? {
    for pair in setproduct(var.app_ports, var.allowed_app_cidrs) : "${pair[0]}-${pair[1]}" => {
      port = pair[0]
      cidr = pair[1]
    }
  } : {}

  security_group_id = aws_security_group.ec2.id
  description       = "Restricted application ingress on port ${each.value.port}"
  cidr_ipv4         = each.value.cidr
  from_port         = each.value.port
  ip_protocol       = "tcp"
  to_port           = each.value.port
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.ec2.id
  description       = "HTTPS egress for apt, Docker, SSM, CloudWatch, and AWS APIs"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "http" {
  security_group_id = aws_security_group.ec2.id
  description       = "HTTP egress for Ubuntu package repositories that redirect to HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "dns_udp" {
  security_group_id = aws_security_group.ec2.id
  description       = "DNS UDP egress"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 53
  ip_protocol       = "udp"
  to_port           = 53
}

resource "aws_vpc_security_group_egress_rule" "dns_tcp" {
  security_group_id = aws_security_group.ec2.id
  description       = "DNS TCP egress"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 53
  ip_protocol       = "tcp"
  to_port           = 53
}

resource "aws_kms_key" "ebs" {
  count = var.create_kms_key ? 1 : 0

  description             = "KMS key for ${var.name_prefix} EC2 EBS encryption"
  deletion_window_in_days = var.kms_deletion_window
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ebs-kms"
  })
}

resource "aws_kms_alias" "ebs" {
  count = var.create_kms_key ? 1 : 0

  name          = "alias/${var.name_prefix}-ebs"
  target_key_id = aws_kms_key.ebs[0].key_id
}
