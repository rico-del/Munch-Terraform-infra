variable "name_prefix" {
  type        = string
  description = "Name prefix for network resources."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block."
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR block."
}

variable "private_subnet_cidr" {
  type        = string
  description = "Private subnet CIDR block."
}

variable "availability_zone" {
  type        = string
  description = "Optional AZ override for primary subnets."
  default     = null
}

variable "secondary_availability_zone" {
  type        = string
  description = "Optional AZ override for secondary subnets."
  default     = null
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to create a NAT Gateway for private subnet egress."
}

variable "single_nat_gateway" {
  type        = bool
  description = "Reserved for future multi-AZ expansion; initial topology uses one AZ."
}

variable "assign_public_ip" {
  type        = bool
  description = "Whether public subnet should map public IPs on launch."
}

variable "enable_secondary_public_subnet" {
  type        = bool
  description = "Create a second public subnet in another AZ for ALB/ASG readiness."
  default     = true
}

variable "secondary_public_subnet_cidr" {
  type        = string
  description = "CIDR block for the optional secondary public subnet."
  default     = "10.40.2.0/24"
}

variable "enable_secondary_private_subnet" {
  type        = bool
  description = "Create a second private subnet in another AZ for database/compute readiness."
  default     = false
}

variable "secondary_private_subnet_cidr" {
  type        = string
  description = "CIDR block for the optional secondary private subnet."
  default     = "10.40.12.0/24"
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
