
# Output the bucket names and table name
output "dev_bucket_name" {
  value = aws_s3_bucket.terraform_state_dev.bucket
}

output "prod_bucket_name" {
  value = aws_s3_bucket.terraform_state_prod.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}