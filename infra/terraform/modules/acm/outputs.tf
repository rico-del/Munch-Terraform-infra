output "certificate_arn" {
  value       = try(aws_acm_certificate.this[0].arn, null)
  description = "ACM Certificate ARN."
}

output "domain_validation_options" {
  value       = try(aws_acm_certificate.this[0].domain_validation_options, [])
  description = "DNS domain validation options for DNS record creation."
}
