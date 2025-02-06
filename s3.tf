resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-SF-remote"
  tags = {
    Name        = "Terraform State Bucket"
    Environment = "DevOps Journey"
  }
}
