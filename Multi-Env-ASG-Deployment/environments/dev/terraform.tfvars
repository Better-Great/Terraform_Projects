# AWS Configuration
aws_region = "us-east-1"

# Environment
environment  = "dev"
project_name = "webapp"
owner        = "devops-team"

# Network Configuration
vpc_cidr = "10.0.0.0/16"

public_subnet_cidrs = [
  "10.0.1.0/24", # us-east-1a
  "10.0.2.0/24"  # us-east-1b
]

private_subnet_cidrs = [
  "10.0.10.0/24", # us-east-1a
  "10.0.11.0/24"  # us-east-1b
]

database_subnet_cidrs = [
  "10.0.20.0/24", # us-east-1a
  "10.0.21.0/24"  # us-east-1b
]

# Application Configuration
app_port = 8080
db_port  = 5432

# EC2 Configuration
instance_type = "t3.micro"
key_pair_name = "dev-keypair" # Make sure this key pair exists in your AWS account

# Auto Scaling (Dev - smaller scale)
asg_min_size         = 1
asg_max_size         = 3
asg_desired_capacity = 2

# Database Configuration
db_name              = "webappdb"
db_username          = "admin"
db_password          = "DevPassword123!" # Change this to a secure password
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20