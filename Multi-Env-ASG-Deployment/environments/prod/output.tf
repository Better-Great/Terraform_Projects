# Application URL
output "application_url" {
  description = "Application Load Balancer URL"
  value       = "http://${module.compute.alb_dns_name}"
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.compute.alb_dns_name
}

# Database Information
output "database_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_instance_endpoint
  sensitive   = true
}

# VPC Information
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

# Auto Scaling Group
output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.compute.asg_name
}

# Environment Info
output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}