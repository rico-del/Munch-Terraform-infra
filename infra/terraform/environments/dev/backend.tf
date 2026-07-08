/*
  Optional remote state backend.

  Terraform backend blocks cannot use variables. Before enabling this block,
  bootstrap the S3 bucket and DynamoDB table described in README.md, then
  uncomment and edit the values for your AWS account/region.
*/

# terraform {
#   backend "s3" {
#     bucket         = "REPLACE_WITH_UNIQUE_TF_STATE_BUCKET"
#     key            = "munch-catering/dev/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-locks"
#     encrypt        = true
#   }
# }
