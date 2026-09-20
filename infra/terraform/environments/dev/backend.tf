#left out Dynamo DB since Modern Terraform supports native S3 state locking when using recent Terraform versions and AWS provider support.

terraform {
  backend "s3" {
    key     = "munch-catering/dev/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
    # Native S3 state locking (Terraform >=1.10): prevents two writers
    # from silently overwriting each other. Requires s3:PutObject on
    # <key>.tflock in the state bucket.
    use_lockfile = true
  }
}
