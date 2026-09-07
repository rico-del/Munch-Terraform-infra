variable "project_name" {
  type        = string
  description = "Project name slug."
  default     = "munch-catering"
}

variable "environment" {
  type        = string
  description = "Environment name."
  default     = "dev"
}

variable "atlas_org_id" {
  type        = string
  description = "MongoDB Atlas Organization ID."
}

variable "atlas_region_name" {
  type        = string
  description = "Atlas AWS region (e.g. EU_WEST_1)."
  default     = "EU_WEST_1"
}

variable "cluster_instance_size" {
  type        = string
  description = "Atlas cluster instance size (e.g. M0, M10)."
  default     = "M0"
}

variable "database_name" {
  type        = string
  description = "Application database name."
  default     = "munch_catering"
}

variable "db_username" {
  type        = string
  description = "MongoDB database application user username."
  default     = "munch_app_user"
}

variable "db_password" {
  type        = string
  description = "MongoDB database application user password."
  sensitive   = true
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to access Atlas cluster (e.g. NAT Gateway IP or VPC CIDR)."
  default     = ["0.0.0.0/0"]
}
