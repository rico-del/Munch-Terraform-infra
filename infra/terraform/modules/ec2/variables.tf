variable "name_prefix" {
  type        = string
  description = "Name prefix for EC2 resources."
}

variable "ami_id" {
  type        = string
  description = "Optional AMI ID override."
  default     = null
  nullable    = true
}

variable "ubuntu_release" {
  type        = string
  description = "Ubuntu release for AMI lookup."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
}

variable "cpu_credits" {
  type        = string
  description = "T-series CPU credit setting."
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for EC2."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs for EC2."
}

variable "iam_instance_profile_name" {
  type        = string
  description = "IAM instance profile name."
}

variable "assign_public_ip" {
  type        = bool
  description = "Assign public IP address."
}

variable "root_volume_size_gb" {
  type        = number
  description = "Root EBS volume size."
}

variable "root_volume_type" {
  type        = string
  description = "Root EBS volume type."
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ARN for root EBS encryption."
  default     = null
  nullable    = true
}

variable "enable_cloudwatch_agent" {
  type        = bool
  description = "Install CloudWatch agent."
}

variable "cloudwatch_log_group_name" {
  type        = string
  description = "CloudWatch log group name."
  default     = null
  nullable    = true
}

variable "app_directory" {
  type        = string
  description = "Application directory."
}

variable "ssm_parameter_prefix" {
  type        = string
  description = "SSM parameter prefix for runtime config."
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
