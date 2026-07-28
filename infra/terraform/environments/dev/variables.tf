variable "aws_region" {
  description = "AWS region where dev infrastructure will be provisioned."
  type        = string
  default     = "eu-west-1"
}

variable "availability_zone" {
  description = "Optional AZ for both initial subnets. Leave null to let AWS choose by region data source."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Short project slug used in names and tags."
  type        = string
  default     = "munch-catering"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,40}$", var.project_name))
    error_message = "project_name must be 3-40 characters and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Business or engineering owner tag."
  type        = string
  default     = "platform-engineering"
}

variable "additional_tags" {
  description = "Additional tags merged into every supported resource."
  type        = map(string)
  default     = {}
}

variable "dry_run_mode" {
  description = "Safe default. When true, no AWS resources are created. Set false after reviewing plan and tfvars."
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.40.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
  default     = "10.40.11.0/24"
}

variable "enable_nat_gateway" {
  description = "Create NAT Gateway for private subnet outbound internet. Costs apply; disabled by default."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway for cost control. Multi-AZ NAT is preferred for production HA."
  type        = bool
  default     = true
}

variable "assign_public_ip" {
  description = "Assign a public IPv4 address to the EC2 instance. Use SSM and minimal ingress when true."
  type        = bool
  default     = true
}

variable "enable_public_ssh" {
  description = "Allow inbound SSH only from allowed_ssh_cidr. Disabled by default; prefer SSM Session Manager."
  type        = bool
  default     = false
}

variable "use_ssm" {
  description = "Keep SSM Session Manager enabled for secure administrative access."
  type        = bool
  default     = true
}

variable "allowed_ssh_cidr" {
  description = "Trusted IPv4 CIDR for SSH when enable_public_ssh is true. Null disables SSH ingress."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.allowed_ssh_cidr == null || can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "allowed_ssh_cidr must be null or a valid IPv4 CIDR, for example 203.0.113.10/32."
  }
}

variable "open_app_ports" {
  description = "Open app ports from allowed_app_cidrs. Disabled by default; production should use ALB + ACM + WAF."
  type        = bool
  default     = true
}

variable "allowed_app_cidrs" {
  description = "CIDRs allowed to reach app_ports when open_app_ports is true."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for cidr in var.allowed_app_cidrs : can(cidrhost(cidr, 0))])
    error_message = "Every allowed_app_cidrs value must be a valid IPv4 CIDR."
  }
}

variable "app_ports" {
  description = "Application ports to expose only when open_app_ports is true."
  type        = list(number)
  default     = [80, 443]

  validation {
    condition     = alltrue([for port in var.app_ports : port > 0 && port <= 65535])
    error_message = "Every app port must be between 1 and 65535."
  }
}

variable "ami_id" {
  description = "Optional AMI ID override. Leave null to select the latest Canonical Ubuntu AMI."
  type        = string
  default     = null
  nullable    = true
}

variable "ubuntu_release" {
  description = "Ubuntu LTS release used when ami_id is null."
  type        = string
  default     = "24.04"

  validation {
    condition     = contains(["22.04", "24.04"], var.ubuntu_release)
    error_message = "ubuntu_release must be 22.04 or 24.04."
  }
}

variable "instance_type" {
  description = "EC2 instance size for the initial Docker Compose host. Default is Free Tier oriented; larger sizes are healthier for the full platform but may cost money."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro", "t3.small", "t3.medium", "t3.large"], var.instance_type)
    error_message = "Use a vetted t2/t3 instance type unless the module is reviewed for another host family."
  }
}

variable "cpu_credits" {
  description = "T-series CPU credit option. Use standard for Free Tier cost control; unlimited can incur surplus credit charges."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "unlimited"], var.cpu_credits)
    error_message = "cpu_credits must be standard or unlimited."
  }
}

variable "root_volume_size_gb" {
  description = "Encrypted root EBS volume size. AWS Free Tier includes up to 30 GB of EBS storage for eligible accounts."
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size_gb >= 8 && var.root_volume_size_gb <= 1024
    error_message = "root_volume_size_gb must be between 8 and 1024."
  }
}

variable "root_volume_type" {
  description = "Root EBS volume type."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp3", "io2"], var.root_volume_type)
    error_message = "root_volume_type must be gp3 or io2."
  }
}

variable "create_kms_key" {
  description = "Create a customer-managed KMS key for EBS encryption. Disabled by default for Free Tier optimization; AWS-managed EBS encryption is still used."
  type        = bool
  default     = false
}

variable "kms_deletion_window" {
  description = "KMS key deletion window in days."
  type        = number
  default     = 30

  validation {
    condition     = var.kms_deletion_window >= 7 && var.kms_deletion_window <= 30
    error_message = "kms_deletion_window must be between 7 and 30 days."
  }
}

variable "enable_cloudwatch_agent" {
  description = "Install CloudWatch agent and create log group. Optional to reduce cost/noise in dev."
  type        = bool
  default     = false
}

variable "cloudwatch_log_retention_days" {
  description = "Retention period for the optional EC2 application log group."
  type        = number
  default     = 30
}

variable "app_directory" {
  description = "Secure application directory created by user_data."
  type        = string
  default     = "/opt/munch-catering"
}

variable "ssm_parameter_prefix" {
  description = "Prefix for runtime configuration/secrets stored outside Terraform state."
  type        = string
  default     = "/munch-catering/dev"
}

variable "example_secret_names" {
  description = "Example names for SSM SecureString or Secrets Manager values. Values are intentionally not managed by Terraform."
  type        = list(string)
  default = [
    "database_url",
    "postgres_password",
    "redis_password",
    "jwt_secret",
    "grafana_admin_password",
    "openai_api_key"
  ]
}
