output "example_secret_parameter_paths" {
  value       = local.example_secret_parameter_paths
  description = "Example SSM SecureString parameter paths. Values are intentionally unmanaged."
}

output "app_directory_parameter_name" {
  value       = aws_ssm_parameter.app_directory.name
  description = "Non-secret app directory parameter."
}
