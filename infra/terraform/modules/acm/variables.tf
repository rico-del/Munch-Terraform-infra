variable "name_prefix" {
  type        = string
  description = "Name prefix for ACM resources."
}

variable "environment" {
  type        = string
  description = "Deployment environment name."
}

variable "create_certificate" {
  type        = bool
  description = "Whether to create a new ACM certificate."
  default     = false
}

variable "domain_name" {
  type        = string
  description = "Primary domain name for the ACM certificate (e.g. munch.example.com)."
  default     = null
  nullable    = true
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Subject Alternative Names (SANs) for the certificate."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to ACM resources."
  default     = {}
}
