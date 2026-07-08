variable "name_prefix" {
  type        = string
  description = "Name prefix for monitoring resources."
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days."
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
