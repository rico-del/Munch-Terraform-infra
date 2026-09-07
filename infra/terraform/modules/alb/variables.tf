variable "name_prefix" {
  type        = string
  description = "Name prefix for ALB resources."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the target groups belong."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs where the ALB is provisioned (minimum 2 in different AZs)."
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for the ALB."
}

variable "target_port" {
  type        = number
  description = "Port on instances that receive traffic."
  default     = 80
}

variable "health_check_path" {
  type        = string
  description = "HTTP path for target group health checks."
  default     = "/health"
}

variable "active_slot" {
  type        = string
  description = "Active deployment slot: 'blue' or 'green'."
  default     = "blue"

  validation {
    condition     = contains(["blue", "green"], var.active_slot)
    error_message = "active_slot must be either 'blue' or 'green'."
  }
}

variable "enable_https" {
  type        = bool
  description = "Enable HTTPS listener on port 443 (requires certificate_arn)."
  default     = false
}

variable "certificate_arn" {
  type        = string
  description = "ACM Certificate ARN for the HTTPS listener."
  default     = null
  nullable    = true
}

variable "redirect_http_to_https" {
  type        = bool
  description = "Redirect HTTP port 80 traffic to HTTPS port 443."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all ALB resources."
  default     = {}
}
