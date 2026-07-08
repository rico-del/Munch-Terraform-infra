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

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
  enable_nat_gateway  = var.enable_nat_gateway
  single_nat_gateway  = var.single_nat_gateway
  assign_public_ip    = var.assign_public_ip
  tags                = local.common_tags
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
  tags = local.common_tags
}

module "ssm" {
  count = local.resource_enabled ? 1 : 0

  source = "../../modules/ssm"

  name_prefix          = local.name_prefix
  ssm_parameter_prefix = var.ssm_parameter_prefix
  example_secret_names = var.example_secret_names
  app_directory        = var.app_directory
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
  open_app_ports      = local.app_ports_enabled
  allowed_app_cidrs   = var.allowed_app_cidrs
  app_ports           = var.app_ports
  create_kms_key      = var.create_kms_key
  kms_deletion_window = var.kms_deletion_window
  tags                = local.common_tags
}

module "ec2" {
  count = local.resource_enabled ? 1 : 0

  source = "../../modules/ec2"

  name_prefix               = local.name_prefix
  ami_id                    = var.ami_id
  ubuntu_release            = var.ubuntu_release
  instance_type             = var.instance_type
  cpu_credits               = var.cpu_credits
  subnet_id                 = var.assign_public_ip ? module.network[0].public_subnet_id : module.network[0].private_subnet_id
  security_group_ids        = [module.security[0].ec2_security_group_id]
  iam_instance_profile_name = module.iam[0].instance_profile_name
  assign_public_ip          = var.assign_public_ip
  root_volume_size_gb       = var.root_volume_size_gb
  root_volume_type          = var.root_volume_type
  kms_key_id                = module.security[0].kms_key_arn
  enable_cloudwatch_agent   = var.enable_cloudwatch_agent
  cloudwatch_log_group_name = try(module.monitoring[0].log_group_name, null)
  app_directory             = var.app_directory
  ssm_parameter_prefix      = var.ssm_parameter_prefix
  tags                      = local.common_tags
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
