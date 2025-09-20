terraform {
  backend "s3" {
    bucket         = "terraform-state-webapp-dev-9850fbb5"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-webapp"
    encrypt        = true
  }
}
