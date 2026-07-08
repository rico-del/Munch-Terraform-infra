variable "name_prefix" {
  type        = string
  description = "Name prefix for security resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "enable_public_ssh" {
  type        = bool
  description = "Whether to create restricted SSH ingress."
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "Trusted SSH CIDR."
  default     = null
  nullable    = true
}

variable "open_app_ports" {
  type        = bool
  description = "Whether to create restricted app ingress."
}

variable "allowed_app_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach app ports."
  default     = []
}

variable "app_ports" {
  type        = list(number)
  description = "Application ports to expose."
  default     = []
}

variable "create_kms_key" {
  type        = bool
  description = "Whether to create a customer-managed KMS key."
}

variable "kms_deletion_window" {
  type        = number
  description = "KMS deletion window."
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
