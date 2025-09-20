terraform {
  backend "s3" {
    bucket         = "terraform-state-webapp-prod-9850fbb5"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-webapp"
    encrypt        = true
  }
}
