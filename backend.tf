# # Purpose: Configure an S3 bucket as the backend for the Terraform state file. This will store the Terraform state file securely in an S3 bucket.
# terraform {
#   backend "s3" {
#     bucket = "terraform-SF-remote"
#     key    = "lab1/terraform.tfstate"
#     region = "us-east-1"
#     # dynamodb_table = "remote-state-lock" // To enable locking for the state file in the S3 bucket using DynamoDB table. This will prevent concurrent modifications to the state file.
#   }
# }

