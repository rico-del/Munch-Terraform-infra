output "vpc_id" {
  value       = aws_vpc.this.id
  description = "VPC ID."
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "Public subnet ID."
}

output "public_subnet_ids" {
  value       = concat([aws_subnet.public.id], try([aws_subnet.public_secondary[0].id], []))
  description = "Public subnet IDs for load balancers and public compute."
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "Primary private subnet ID."
}

output "private_subnet_ids" {
  value       = concat([aws_subnet.private.id], try([aws_subnet.private_secondary[0].id], []))
  description = "Private subnet IDs for database and private compute tiers."
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.this.id
  description = "Internet Gateway ID."
}

output "nat_gateway_id" {
  value       = try(aws_nat_gateway.this[0].id, null)
  description = "NAT Gateway ID, if enabled."
}
