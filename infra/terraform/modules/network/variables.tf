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
  description = "Optional AZ override."
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

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}
