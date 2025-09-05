# AWS Configuration
aws_region = "us-east-1"

# Environment
environment  = "prod"
project_name = "webapp"
owner        = "devops-team"

# Network Configuration (Different CIDR to avoid conflicts)
vpc_cidr = "10.1.0.0/16"

public_subnet_cidrs = [
  "10.1.1.0/24",  # us-east-1a
  "10.1.2.0/24"   # us-east-1b
]

private_subnet_cidrs = [
  "10.1.10.0/24", # us-east-1a
  "10.1.11.0/24"  # us-east-1b
]

database_subnet_cidrs = [
  "10.1.20.0/24", # us-east-1a
  "10.1.21.0/24"  # us-east-1b
]

# Application Configuration
app_port = 5000
db_port  = 3306

# EC2 Configuration (Larger instances for production)
instance_type = "t3.small"
key_pair_name = "prod-keypair"  # Make sure this key pair exists in your AWS account

# Auto Scaling (Production - larger scale)
asg_min_size         = 2
asg_max_size         = 10
asg_desired_capacity = 4

# Database Configuration (Production settings)
db_name             = "webappdb"
db_username         = "admin"
db_password         = "ProdSecurePassword456!"  # Change this to a very secure password
db_instance_class   = "db.t3.small"
db_allocated_storage = 20