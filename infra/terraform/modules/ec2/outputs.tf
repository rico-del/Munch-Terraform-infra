output "launch_template_id" {
  value       = aws_launch_template.this.id
  description = "Launch Template ID."
}

output "launch_template_arn" {
  value       = aws_launch_template.this.arn
  description = "Launch Template ARN."
}

output "launch_template_latest_version" {
  value       = aws_launch_template.this.latest_version
  description = "Launch Template latest version."
}

output "asg_id" {
  value       = aws_autoscaling_group.this.id
  description = "Primary (Blue) Auto Scaling Group ID."
}

output "asg_name" {
  value       = aws_autoscaling_group.this.name
  description = "Primary (Blue) Auto Scaling Group Name."
}

output "asg_arn" {
  value       = aws_autoscaling_group.this.arn
  description = "Primary (Blue) Auto Scaling Group ARN."
}

output "green_asg_id" {
  value       = try(aws_autoscaling_group.green[0].id, null)
  description = "Standby (Green) Auto Scaling Group ID, if enabled."
}

output "green_asg_name" {
  value       = try(aws_autoscaling_group.green[0].name, null)
  description = "Standby (Green) Auto Scaling Group Name, if enabled."
}

output "legacy_instance_id" {
  value       = try(aws_instance.this[0].id, null)
  description = "Legacy EC2 instance ID if preserved during migration."
}

output "legacy_public_ip" {
  value       = try(aws_instance.this[0].public_ip, null)
  description = "Legacy EC2 public IP if preserved during migration."
}

output "legacy_private_ip" {
  value       = try(aws_instance.this[0].private_ip, null)
  description = "Legacy EC2 private IP if preserved during migration."
}

output "green_asg_arn" {
  value       = try(aws_autoscaling_group.green[0].arn, null)
  description = "Standby (Green) Auto Scaling Group ARN, if enabled."
}
