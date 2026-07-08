output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC ID."
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "Public subnet ID."
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "Private subnet ID."
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.this.id
  description = "Internet Gateway ID."
}

output "nat_gateway_id" {
  value       = try(aws_nat_gateway.this[0].id, null)
  description = "NAT Gateway ID, if enabled."
}
