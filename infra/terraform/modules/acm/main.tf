resource "aws_acm_certificate" "this" {
  count             = var.create_certificate && var.domain_name != null ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = var.subject_alternative_names

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-acm-cert"
    Environment = var.environment
  })

  lifecycle {
    create_before_destroy = true
  }
}
