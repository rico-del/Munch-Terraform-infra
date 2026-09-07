output "alb_id" {
  value       = aws_lb.this.id
  description = "Application Load Balancer ID."
}

output "alb_arn" {
  value       = aws_lb.this.arn
  description = "Application Load Balancer ARN."
}

output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "Application Load Balancer DNS name."
}

output "alb_zone_id" {
  value       = aws_lb.this.zone_id
  description = "Application Load Balancer Route 53 zone ID."
}

output "target_group_arn" {
  value       = var.active_slot == "green" ? aws_lb_target_group.green.arn : aws_lb_target_group.blue.arn
  description = "Active target group ARN currently receiving production traffic."
}

output "blue_target_group_arn" {
  value       = aws_lb_target_group.blue.arn
  description = "Blue target group ARN."
}

output "green_target_group_arn" {
  value       = aws_lb_target_group.green.arn
  description = "Green target group ARN."
}

output "blue_target_group_name" {
  value       = aws_lb_target_group.blue.name
  description = "Blue target group name."
}

output "green_target_group_name" {
  value       = aws_lb_target_group.green.name
  description = "Green target group name."
}

output "http_listener_arn" {
  value       = aws_lb_listener.http.arn
  description = "HTTP listener ARN."
}

output "https_listener_arn" {
  value       = try(aws_lb_listener.https[0].arn, null)
  description = "HTTPS listener ARN (port 443), if enabled."
}

output "test_listener_arn" {
  value       = aws_lb_listener.test.arn
  description = "HTTP test listener ARN (port 8080) for pre-cutover testing of the inactive slot."
}

output "inactive_target_group_arn" {
  value       = var.active_slot == "green" ? aws_lb_target_group.blue.arn : aws_lb_target_group.green.arn
  description = "Inactive target group ARN currently receiving test traffic on port 8080."
}
