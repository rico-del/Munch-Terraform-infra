#left out Dynamo DB since Modern Terraform supports native S3 state locking when using recent Terraform versions and AWS provider support.

terraform {
  backend "s3" {
    key    = "munch-catering/dev/terraform.tfstate"
    region = "eu-west-1"

    encrypt = true
  }
}
