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

variable "enable_alb" {
  type        = bool
  description = "Whether to create an ALB security group and allow ALB-to-EC2 traffic."
  default     = true
}

variable "alb_ingress_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach the public ALB listener."
  default     = ["0.0.0.0/0"]
}

variable "alb_ingress_ports" {
  type        = list(number)
  description = "Ports open on the public ALB."
  default     = [80, 443, 8080]
}

variable "target_port" {
  type        = number
  description = "Target port on the EC2 instances that the ALB reaches."
  default     = 80
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
