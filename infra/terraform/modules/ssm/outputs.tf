output "config_parameter_names" {
  value = [
    aws_ssm_parameter.config_app_directory.name,
    aws_ssm_parameter.config_ecr_registry.name,
    aws_ssm_parameter.config_s3_bucket_name.name,
  ]
  description = "Terraform-managed non-secret configuration parameter paths."
}

output "deployment_parameter_names" {
  value = [
    aws_ssm_parameter.deploy_blue_image_tag.name,
    aws_ssm_parameter.deploy_green_image_tag.name,
  ]
  description = "Terraform-created deployment parameter paths updated by GitHub Actions."
}
