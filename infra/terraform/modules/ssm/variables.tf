variable "name_prefix" {
  type        = string
  description = "Name prefix."
}

variable "ssm_parameter_prefix" {
  type        = string
  description = "Application SSM parameter prefix."
}

variable "app_directory" {
  type        = string
  description = "Application directory path stored as non-secret configuration."
}

variable "ecr_registry" {
  type        = string
  description = "ECR registry domain."
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name for portfolio media."
}

variable "initial_image_tag" {
  type        = string
  description = "Existing immutable image tag used to seed both deployment slots."

  validation {
    condition     = can(regex("^[0-9a-f]{7,64}$", var.initial_image_tag))
    error_message = "initial_image_tag must be an immutable lowercase hexadecimal Git SHA (7-64 characters), never latest."
  }
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
