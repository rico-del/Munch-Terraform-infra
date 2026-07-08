output "instance_id" {
  description = "EC2 instance ID. Null when dry_run_mode is true."
  value       = try(module.ec2[0].instance_id, null)
}

output "public_ip" {
  description = "Public IP address only when assign_public_ip is enabled and resources are created."
  value       = var.assign_public_ip ? try(module.ec2[0].public_ip, null) : null
}

output "private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = try(module.ec2[0].private_ip, null)
}

output "security_group_id" {
  description = "EC2 security group ID."
  value       = try(module.security[0].ec2_security_group_id, null)
}

output "vpc_id" {
  description = "Custom VPC ID."
  value       = try(module.network[0].vpc_id, null)
}

output "ssm_connection_note" {
  description = "How to connect without SSH."
  value       = try("Use: aws ssm start-session --target ${module.ec2[0].instance_id} --region ${var.aws_region}", "Set dry_run_mode=false and apply, then use AWS Systems Manager Session Manager.")
}

output "aws_region" {
  description = "AWS region used by this environment."
  value       = var.aws_region
}

output "example_secret_references" {
  description = "Example parameter paths to create manually as SecureString values. No secret values are output."
  value       = try(module.ssm[0].example_secret_parameter_paths, {})
}
