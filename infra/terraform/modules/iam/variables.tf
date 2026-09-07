variable "name_prefix" {
  type        = string
  description = "Name prefix for IAM resources."
}

variable "enable_cloudwatch_agent" {
  type        = bool
  description = "Attach CloudWatch Agent managed policy."
}

variable "use_ssm" {
  type        = bool
  description = "Attach SSM managed instance core policy."
}

variable "allowed_ssm_parameter_arns" {
  type        = list(string)
  description = "SSM parameter ARNs the EC2 role may read."
}

variable "s3_bucket_arns" {
  type        = list(string)
  description = "S3 bucket ARNs the EC2 role may access for media storage."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
