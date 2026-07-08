variable "name_prefix" {
  type        = string
  description = "Name prefix."
}

variable "ssm_parameter_prefix" {
  type        = string
  description = "Application SSM parameter prefix."
}

variable "example_secret_names" {
  type        = list(string)
  description = "Secret names to document as external SecureString paths."
}

variable "app_directory" {
  type        = string
  description = "Application directory path stored as non-secret metadata."
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
