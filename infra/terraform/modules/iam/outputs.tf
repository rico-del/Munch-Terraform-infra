output "role_name" {
  value       = aws_iam_role.ec2.name
  description = "EC2 IAM role name."
}

output "instance_profile_name" {
  value       = aws_iam_instance_profile.ec2.name
  description = "EC2 instance profile name."
}
