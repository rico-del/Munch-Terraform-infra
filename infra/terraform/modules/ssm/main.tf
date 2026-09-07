resource "aws_ssm_parameter" "config_app_directory" {
  name        = "${var.ssm_parameter_prefix}/config/app_directory"
  description = "Application directory path for ${var.name_prefix}."
  type        = "String"
  value       = var.app_directory

  tags = merge(var.tags, {
    Name     = "${var.name_prefix}-config-app-directory"
    Category = "config"
  })
}

# Retained for the already-managed parameter in remote state. Bootstrap reads
# only config/app_directory, so this path is compatibility metadata, not a
# second runtime source of truth.
resource "aws_ssm_parameter" "app_directory" {
  name        = "${var.ssm_parameter_prefix}/app_directory"
  description = "Non-secret app directory for ${var.name_prefix}."
  type        = "String"
  value       = var.app_directory

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-directory"
  })
}

resource "aws_ssm_parameter" "config_ecr_registry" {
  name        = "${var.ssm_parameter_prefix}/config/ecr_registry"
  description = "ECR registry domain for ${var.name_prefix}."
  type        = "String"
  value       = var.ecr_registry

  tags = merge(var.tags, {
    Name     = "${var.name_prefix}-config-ecr-registry"
    Category = "config"
  })
}

resource "aws_ssm_parameter" "config_s3_bucket_name" {
  name        = "${var.ssm_parameter_prefix}/config/s3_bucket_name"
  description = "S3 bucket name for portfolio media."
  type        = "String"
  value       = var.s3_bucket_name

  tags = merge(var.tags, {
    Name     = "${var.name_prefix}-config-s3-bucket-name"
    Category = "config"
  })
}

# Terraform creates the first immutable tag; GitHub Actions updates slot values after deploys.
resource "aws_ssm_parameter" "deploy_blue_image_tag" {
  name        = "${var.ssm_parameter_prefix}/deploy/blue/image_tag"
  description = "Image tag deployed to blue slot for ${var.name_prefix}."
  type        = "String"
  value       = var.initial_image_tag

  tags = merge(var.tags, {
    Name     = "${var.name_prefix}-deploy-blue-image-tag"
    Category = "deploy"
    Slot     = "blue"
  })

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "deploy_green_image_tag" {
  name        = "${var.ssm_parameter_prefix}/deploy/green/image_tag"
  description = "Image tag deployed to green slot for ${var.name_prefix}."
  type        = "String"
  value       = var.initial_image_tag

  tags = merge(var.tags, {
    Name     = "${var.name_prefix}-deploy-green-image-tag"
    Category = "deploy"
    Slot     = "green"
  })

  lifecycle {
    ignore_changes = [value]
  }
}
