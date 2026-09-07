data "aws_ami" "ubuntu" {
  count = var.ami_id == null ? 1 : 0

  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/${local.ubuntu_codename}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ubuntu_codename = var.ubuntu_release == "22.04" ? "ubuntu-jammy-22.04" : "ubuntu-noble-24.04"
  ami_id          = coalesce(var.ami_id, data.aws_ami.ubuntu[0].id)
}

moved {
  from = aws_instance.this
  to   = aws_instance.this[0]
}

moved {
  from = aws_eip.this
  to   = aws_eip.this[0]
}

moved {
  from = aws_eip_association.this
  to   = aws_eip_association.this[0]
}

resource "aws_instance" "this" {
  count                       = var.preserve_legacy_instance ? 1 : 0
  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = coalesce(var.primary_subnet_id, var.subnet_ids[0])
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.iam_instance_profile_name
  associate_public_ip_address = var.assign_public_ip
  user_data_replace_on_change = true
  user_data_base64 = base64encode(templatefile("${path.module}/templates/user_data.sh.tftpl", {
    app_directory           = var.app_directory
    enable_cloudwatch_agent = var.enable_cloudwatch_agent
    cloudwatch_log_group    = var.cloudwatch_log_group_name
    ssm_parameter_prefix    = var.ssm_parameter_prefix
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  credit_specification {
    cpu_credits = var.cpu_credits
  }

  root_block_device {
    encrypted             = true
    kms_key_id            = var.kms_key_id
    volume_size           = var.root_volume_size_gb
    volume_type           = var.root_volume_type
    delete_on_termination = true

    tags = merge(var.tags, {
      Name = "${var.name_prefix}-root"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-docker-host"
  })

  lifecycle {
    ignore_changes = [
      user_data_base64,
      user_data,
      ami,
    ]
  }
}

resource "aws_eip" "this" {
  count  = var.preserve_legacy_instance ? 1 : 0
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eip"
  })
}

resource "aws_eip_association" "this" {
  count         = var.preserve_legacy_instance ? 1 : 0
  instance_id   = aws_instance.this[0].id
  allocation_id = aws_eip.this[0].id
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = local.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh.tftpl", {
    app_directory           = var.app_directory
    enable_cloudwatch_agent = var.enable_cloudwatch_agent
    cloudwatch_log_group    = var.cloudwatch_log_group_name
    ssm_parameter_prefix    = var.ssm_parameter_prefix
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  credit_specification {
    cpu_credits = var.cpu_credits
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.root_volume_size_gb
      volume_type           = var.root_volume_type
      encrypted             = true
      kms_key_id            = var.kms_key_id
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-asg-node"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-asg-root"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-launch-template"
  })
}

resource "aws_autoscaling_group" "this" {
  name_prefix         = "${var.name_prefix}-asg-blue-"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type         = length(var.target_group_arns) > 0 ? "ELB" : "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
      instance_warmup        = 300
    }
  }

  dynamic "tag" {
    for_each = merge(var.tags, {
      Name = "${var.name_prefix}-asg-instance"
      Slot = "blue"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_autoscaling_group" "green" {
  count               = var.enable_green_asg ? 1 : 0
  name_prefix         = "${var.name_prefix}-asg-green-"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.green_target_group_arns

  min_size         = var.green_min_size
  max_size         = var.green_max_size
  desired_capacity = var.green_desired_capacity

  health_check_type         = length(var.green_target_group_arns) > 0 ? "ELB" : "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
      instance_warmup        = 300
    }
  }

  dynamic "tag" {
    for_each = merge(var.tags, {
      Name = "${var.name_prefix}-asg-green-instance"
      Slot = "green"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}