# Configure Terraform and required providers
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

  backend "s3" {
    bucket         = "terraform-state-webapp-dev-12345"  # Change this to your unique bucket name
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-webapp"
    encrypt        = true
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Local values for common configurations
locals {
  common_tags = {
    Environment   = var.environment
    Project       = var.project_name
    ManagedBy     = "Terraform"
    Owner         = var.owner
    CreatedDate   = timestamp()
  }
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  # Environment
  environment  = var.environment
  common_tags  = local.common_tags

  # VPC Configuration
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  database_subnet_cidrs   = var.database_subnet_cidrs

  # Application ports
  app_port = var.app_port
  db_port  = var.db_port
}

# Database Module
module "database" {
  source = "../../modules/database"

  # Environment
  environment = var.environment
  common_tags = local.common_tags

  # Networking
  database_subnet_ids        = module.networking.database_subnet_ids
  database_security_group_id = module.networking.database_security_group_id

  # Database Configuration
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  db_instance_class   = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  
  # Dev-specific settings
  multi_az            = false  # Single AZ for cost savings in dev
  deletion_protection = false  # Allow easy cleanup in dev
  skip_final_snapshot = true   # Skip snapshot for dev
}

# Compute Module
module "compute" {
  source = "../../modules/compute"

  # Environment
  environment = var.environment
  common_tags = local.common_tags

  # Networking
  vpc_id                   = module.networking.vpc_id
  public_subnet_ids        = module.networking.public_subnet_ids
  private_subnet_ids       = module.networking.private_subnet_ids
  alb_security_group_id    = module.networking.alb_security_group_id
  web_security_group_id    = module.networking.web_security_group_id

  # Application Configuration
  app_port      = var.app_port
  instance_type = var.instance_type
  key_pair_name = var.key_pair_name

  # Auto Scaling
  asg_min_size         = var.asg_min_size
  asg_max_size         = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity

  # Database Connection
  db_endpoint = module.database.db_instance_endpoint
  db_name     = module.database.db_name
  db_username = module.database.db_username
  db_password = module.database.db_password

  depends_on = [module.networking, module.database]
}