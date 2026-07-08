locals {
  example_secret_parameter_paths = {
    for name in var.example_secret_names : name => "${var.ssm_parameter_prefix}/${name}"
  }
}

resource "aws_ssm_parameter" "app_directory" {
  name        = "${var.ssm_parameter_prefix}/app_directory"
  description = "Non-secret app directory for ${var.name_prefix}."
  type        = "String"
  value       = var.app_directory

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-directory"
  })
}
