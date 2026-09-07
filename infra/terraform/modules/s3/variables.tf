variable "name_prefix" {
  type        = string
  description = "Name prefix for S3 resources."
}

variable "environment" {
  type        = string
  description = "Deployment environment name."
}

variable "account_id" {
  type        = string
  description = "AWS Account ID for globally unique bucket naming."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to S3 resources."
  default     = {}
}
