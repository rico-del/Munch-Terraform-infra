output "ec2_security_group_id" {
  value       = aws_security_group.ec2.id
  description = "EC2 security group ID."
}

output "kms_key_arn" {
  value       = try(aws_kms_key.ebs[0].arn, null)
  description = "Customer-managed KMS key ARN, if created."
}
