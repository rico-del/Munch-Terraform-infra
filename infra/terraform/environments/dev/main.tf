terraform {
  required_version = ">= 1.6.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix       = "${var.project_name}-${var.environment}"
  resource_enabled  = !var.dry_run_mode
  ssh_enabled       = var.enable_public_ssh && var.allowed_ssh_cidr != null
  app_ports_enabled = var.open_app_ports && length(var.allowed_app_cidrs) > 0

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
      Application = var.project_name
    },
    var.additional_tags
  )
}

module "network" {
  count = local.resource_enabled ? 1 : 0

  source = "../../modules/network"

  name_prefix                    = local.name_prefix
  vpc_cidr                       = var.vpc_cidr
  public_subnet_cidr             = var.public_subnet_cidr
  private_subnet_cidr            = var.private_subnet_cidr
  availability_zone              = var.availability_zone
  enable_secondary_public_subnet = true
  enable_nat_gateway             = var.enable_nat_gateway
  single_nat_gateway             = var.single_nat_gateway
  assign_public_ip               = var.assign_public_ip
  tags                           = local.common_tags
}

module "s3" {
  count = local.resource_enabled ? 1 : 0

  source = "../../modules/s3"

  name_prefix = local.name_prefix
  environment = var.environment
  account_id  = data.aws_caller_identity.current.account_id
  tags        = local.common_tags
}

module "iam" {
  count = local.resource_enabled ? 1 : 0

  source = "../../modules/iam"

  name_prefix             = local.name_prefix
  enable_cloudwatch_agent = var.enable_cloudwatch_agent
  use_ssm                 = var.use_ssm
  allowed_ssm_parameter_arns = [
    "arn:aws:ssm:${var.aws_region}:*:parameter${var.ssm_parameter_prefix}/*"
  ]
  s3_bucket_arns = [try(module.s3[0].bucket_arn, "")]
  tags           = local.common_tags
}

module "ssm" {
  count = local.resource_enabled ? 1 : 0

  source = "../../modules/ssm"

  name_prefix          = local.name_prefix
  ssm_parameter_prefix = var.ssm_parameter_prefix
  app_directory        = var.app_directory
  s3_bucket_name       = try(module.s3[0].bucket_name, null)
  ecr_registry         = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  initial_image_tag    = var.initial_image_tag
  tags                 = local.common_tags
}

module "monitoring" {
  count = local.resource_enabled && var.enable_cloudwatch_agent ? 1 : 0

  source = "../../modules/monitoring"

  name_prefix        = local.name_prefix
  log_retention_days = var.cloudwatch_log_retention_days
  tags               = local.common_tags
}

module "security" {
  count = local.resource_enabled ? 1 : 0

  source = "../../modules/security"

  name_prefix         = local.name_prefix
  vpc_id              = module.network[0].vpc_id
  enable_public_ssh   = local.ssh_enabled
  allowed_ssh_cidr    = var.allowed_ssh_cidr
  enable_alb          = var.enable_alb
  alb_ingress_ports   = var.alb_ingress_ports
  alb_ingress_cidrs   = var.alb_ingress_cidrs
  target_port         = var.app_port
  open_app_ports      = local.app_ports_enabled
  allowed_app_cidrs   = var.allowed_app_cidrs
  app_ports           = var.app_ports
  create_kms_key      = var.create_kms_key
  kms_deletion_window = var.kms_deletion_window
  tags                = local.common_tags
}

module "acm" {
  count = local.resource_enabled && var.create_acm_certificate && var.domain_name != null ? 1 : 0

  source = "../../modules/acm"

  name_prefix               = local.name_prefix
  environment               = var.environment
  create_certificate        = var.create_acm_certificate
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  tags                      = local.common_tags
}

module "alb" {
  count = local.resource_enabled && var.enable_alb ? 1 : 0

  source = "../../modules/alb"

  name_prefix            = local.name_prefix
  vpc_id                 = module.network[0].vpc_id
  subnet_ids             = module.network[0].public_subnet_ids
  security_group_id      = module.security[0].alb_security_group_id
  target_port            = var.app_port
  health_check_path      = var.health_check_path
  active_slot            = var.active_deployment_slot
  enable_https           = var.enable_https
  certificate_arn        = var.certificate_arn != null ? var.certificate_arn : try(module.acm[0].certificate_arn, null)
  redirect_http_to_https = var.redirect_http_to_https
  tags                   = local.common_tags
}

module "ec2" {
  count = local.resource_enabled ? 1 : 0

  source = "../../modules/ec2"

  name_prefix               = local.name_prefix
  preserve_legacy_instance  = var.preserve_legacy_instance
  ami_id                    = var.ami_id
  ubuntu_release            = var.ubuntu_release
  instance_type             = var.instance_type
  cpu_credits               = var.cpu_credits
  primary_subnet_id         = var.assign_public_ip ? module.network[0].public_subnet_id : module.network[0].private_subnet_id
  subnet_ids                = var.assign_public_ip ? module.network[0].public_subnet_ids : [module.network[0].private_subnet_id]
  security_group_ids        = [module.security[0].ec2_security_group_id]
  iam_instance_profile_name = module.iam[0].instance_profile_name
  target_group_arns         = var.enable_alb ? [module.alb[0].blue_target_group_arn] : []
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  enable_green_asg          = var.enable_green_asg
  green_target_group_arns   = var.enable_alb ? [module.alb[0].green_target_group_arn] : []
  green_min_size            = var.green_asg_min_size
  green_max_size            = var.green_asg_max_size
  green_desired_capacity    = var.green_asg_desired_capacity
  assign_public_ip          = var.assign_public_ip
  root_volume_size_gb       = var.root_volume_size_gb
  root_volume_type          = var.root_volume_type
  kms_key_id                = module.security[0].kms_key_arn
  enable_cloudwatch_agent   = var.enable_cloudwatch_agent
  cloudwatch_log_group_name = try(module.monitoring[0].log_group_name, null)
  app_directory             = var.app_directory
  ssm_parameter_prefix      = var.ssm_parameter_prefix
  tags                      = local.common_tags
  depends_on = [
    module.ssm,
    module.s3
  ]
}

check "public_or_nat_egress" {
  assert {
    condition     = var.dry_run_mode || var.assign_public_ip || var.enable_nat_gateway
    error_message = "Either assign_public_ip or enable_nat_gateway must be true so the instance can install Docker and reach SSM. For private-only production, add VPC endpoints before relaxing this check."
  }
}

check "ssm_required" {
  assert {
    condition     = var.use_ssm
    error_message = "use_ssm must remain true for this deployment. Prefer Session Manager over public SSH."
  }
}
