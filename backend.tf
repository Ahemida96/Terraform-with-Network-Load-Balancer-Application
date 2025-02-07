# # Purpose: Configure an S3 bucket as the backend for the Terraform state file. This will store the Terraform state file securely in an S3 bucket.
terraform {
  backend "s3" {
    bucket         = "bucket-name"    # Replace with your bucket name
    key            = "tfstate name"   # Replace with your state file name
    region         = "us-east-1"      # Replace with your bucket region
    dynamodb_table = "dynamodb-table" # To enable locking for the state file in the S3 bucket using DynamoDB table. This will prevent concurrent modifications to the state file.
  }
}
