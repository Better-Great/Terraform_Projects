# This file creates the S3 bucket and DynamoDB table for Terraform remote backend
# Run this FIRST before deploying the environments

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Generate random suffix for unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket for Dev Environment State
resource "aws_s3_bucket" "terraform_state_dev" {
  bucket = "terraform-state-webapp-dev-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "Terraform State Dev"
    Environment = "dev"
    Purpose     = "terraform-backend"
  }
}

# S3 Bucket for Prod Environment State
resource "aws_s3_bucket" "terraform_state_prod" {
  bucket = "terraform-state-webapp-prod-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "Terraform State Prod"
    Environment = "prod"
    Purpose     = "terraform-backend"
  }
}

# Enable versioning for dev bucket
resource "aws_s3_bucket_versioning" "terraform_state_dev" {
  bucket = aws_s3_bucket.terraform_state_dev.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable versioning for prod bucket
resource "aws_s3_bucket_versioning" "terraform_state_prod" {
  bucket = aws_s3_bucket.terraform_state_prod.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for dev bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_dev" {
  bucket = aws_s3_bucket.terraform_state_dev.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable encryption for prod bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_prod" {
  bucket = aws_s3_bucket.terraform_state_prod.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access for dev bucket
resource "aws_s3_bucket_public_access_block" "terraform_state_dev" {
  bucket = aws_s3_bucket.terraform_state_dev.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Block public access for prod bucket
resource "aws_s3_bucket_public_access_block" "terraform_state_prod" {
  bucket = aws_s3_bucket.terraform_state_prod.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-webapp"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "Terraform Locks"
    Purpose = "terraform-backend"
  }
}
