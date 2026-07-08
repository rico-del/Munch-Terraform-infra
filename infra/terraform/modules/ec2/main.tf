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

resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
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
    precondition {
      condition     = var.assign_public_ip || var.enable_cloudwatch_agent == false
      error_message = "If assigning no public IP, enable NAT Gateway or VPC endpoints before relying on user_data package installation and CloudWatch agent downloads."
    }
  }
}
