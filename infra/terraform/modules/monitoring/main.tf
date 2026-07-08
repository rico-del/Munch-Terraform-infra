resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ec2/${var.name_prefix}/app"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-logs"
  })
}
