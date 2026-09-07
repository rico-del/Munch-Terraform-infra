output "launch_template_id" {
  description = "AWS Launch Template ID for ASG instances."
  value       = try(module.ec2[0].launch_template_id, null)
}

output "legacy_instance_id" {
  description = "Legacy standalone EC2 instance ID (active during staged transition)."
  value       = try(module.ec2[0].legacy_instance_id, null)
}

output "legacy_public_ip" {
  description = "Legacy standalone EC2 public IP (active during staged transition)."
  value       = try(module.ec2[0].legacy_public_ip, null)
}

output "launch_template_arn" {
  description = "AWS Launch Template ARN."
  value       = try(module.ec2[0].launch_template_arn, null)
}

output "asg_id" {
  description = "Auto Scaling Group ID."
  value       = try(module.ec2[0].asg_id, null)
}

output "asg_name" {
  description = "Auto Scaling Group Name (used for SSM target-by-tag deployments)."
  value       = try(module.ec2[0].asg_name, null)
}

output "asg_arn" {
  description = "Auto Scaling Group ARN."
  value       = try(module.ec2[0].asg_arn, null)
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = try(module.alb[0].alb_dns_name, null)
}

output "alb_arn" {
  description = "Application Load Balancer ARN."
  value       = try(module.alb[0].alb_arn, null)
}

output "alb_zone_id" {
  description = "Application Load Balancer Canonical Hosted Zone ID."
  value       = try(module.alb[0].alb_zone_id, null)
}

output "target_group_arn" {
  description = "Active Target Group ARN receiving traffic from the ALB."
  value       = try(module.alb[0].target_group_arn, null)
}

output "blue_target_group_arn" {
  description = "Blue Target Group ARN."
  value       = try(module.alb[0].blue_target_group_arn, null)
}

output "green_target_group_arn" {
  description = "Green Target Group ARN."
  value       = try(module.alb[0].green_target_group_arn, null)
}

output "https_listener_arn" {
  description = "HTTPS Listener ARN on port 443, if enabled."
  value       = try(module.alb[0].https_listener_arn, null)
}

output "acm_certificate_arn" {
  description = "ACM Certificate ARN managed by Terraform, if enabled."
  value       = try(module.acm[0].certificate_arn, null)
}

output "s3_media_bucket_name" {
  description = "S3 bucket name for portfolio media uploads."
  value       = try(module.s3[0].bucket_name, null)
}

output "s3_media_bucket_arn" {
  description = "S3 bucket ARN for portfolio media uploads."
  value       = try(module.s3[0].bucket_arn, null)
}

output "security_group_id" {
  description = "EC2 application security group ID."
  value       = try(module.security[0].ec2_security_group_id, null)
}

output "alb_security_group_id" {
  description = "ALB security group ID."
  value       = try(module.security[0].alb_security_group_id, null)
}

output "vpc_id" {
  description = "Custom VPC ID."
  value       = try(module.network[0].vpc_id, null)
}

output "public_subnet_ids" {
  description = "Multi-AZ public subnet IDs used by the ALB and ASG."
  value       = try(module.network[0].public_subnet_ids, [])
}

output "ssm_connection_note" {
  description = "How to connect without SSH."
  value       = try("Use: aws ssm send-command --targets 'Key=tag:aws:autoscaling:groupName,Values=${module.ec2[0].asg_name}' --document-name 'AWS-RunShellScript' --region ${var.aws_region}", "Set dry_run_mode=false and apply, then use AWS Systems Manager Session Manager.")
}

output "aws_region" {
  description = "AWS region used by this environment."
  value       = var.aws_region
}
