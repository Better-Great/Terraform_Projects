# Multi-Environment ASG Deployment Guide

This guide will help you deploy a 3-tier Flask application with PostgreSQL database using Terraform on AWS.

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform >= 1.0 installed
3. Appropriate AWS permissions for EC2, RDS, VPC, S3, and DynamoDB

## Architecture

- **Frontend**: Application Load Balancer (direct to Flask app)
- **Application**: Flask web application (Python) with built-in health checks
- **Database**: PostgreSQL RDS instance
- **Infrastructure**: Auto Scaling Group with Application Load Balancer
- **Networking**: VPC with public, private, and database subnets

## Deployment Steps

### Step 1: Create Remote Backend Infrastructure

First, create the S3 bucket and DynamoDB table for Terraform state management:

```bash
cd remote-backend
terraform init
terraform plan
terraform apply
```

**Important**: Note the output values for `dev_bucket_name` and `prod_bucket_name`. You'll need these for the next step.

### Step 2: Configure Backend (Automated)

The backend configuration is now automated! After creating the remote backend, run:

```bash
./configure-backend.sh
```

This script will:
- Retrieve the bucket names from the remote backend outputs
- Create `backend.tf` files for each environment with the correct bucket names
- Set up the DynamoDB table reference

**Manual Alternative**: If you prefer manual configuration, you can also run the full deployment script:
```bash
./deploy.sh dev
```

### Step 3: Deploy Development Environment

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

The deployment will create:
- VPC with public, private, and database subnets
- PostgreSQL RDS instance
- Auto Scaling Group with t3.micro instances
- Application Load Balancer
- Security groups and networking components
- SSH key pair (saved as `dev-keypair.pem` in the dev directory)

### Step 4: Access the Application

After deployment completes:

1. Get the ALB DNS name from the Terraform output:
   ```bash
   terraform output alb_dns_name
   ```

2. Open your browser and navigate to the ALB DNS name
3. You should see the Flask user management application

### Step 5: SSH Access (Optional)

If you need to access the EC2 instances:

```bash
# Make the key file secure
chmod 600 dev-keypair.pem

# SSH to an instance (get instance IP from AWS Console)
ssh -i dev-keypair.pem ubuntu@<INSTANCE_IP>
```

## Application Features

The deployed Flask application includes:

- **User Registration**: Create new users with encrypted passwords
- **Data Retrieval**: Search for users by ID
- **Data Management**: Delete users
- **PostgreSQL Integration**: All data stored in RDS PostgreSQL database

## Configuration Details

### Instance Configuration
- **Instance Type**: t3.micro (smallest size as requested)
- **Operating System**: Ubuntu 22.04 LTS
- **Auto Scaling**: Min 1, Max 3, Desired 2 instances

### Database Configuration
- **Engine**: PostgreSQL 15.4
- **Instance Class**: db.t3.micro
- **Storage**: 20 GB with auto-scaling up to 100 GB
- **Multi-AZ**: Disabled in dev (enabled in prod)

### Security
- ALB accepts traffic on port 80 from internet
- Web servers only accept traffic from ALB on port 8080 (Flask app direct)
- Database only accepts traffic from web servers on port 5432
- SSH access available on port 22 (restricted to your IP)
- No nginx layer - simplified architecture

## Monitoring and Health Checks

- ALB health checks configured for `/health` endpoint
- CloudWatch alarms for CPU utilization
- Auto scaling based on CPU metrics

## Cleanup

To destroy the infrastructure:

```bash
# Destroy environment
cd environments/dev
terraform destroy

# Destroy remote backend (optional)
cd ../../remote-backend
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Backend bucket doesn't exist**: Make sure you completed Step 1 and updated the bucket name in Step 2
2. **Permission denied**: Ensure your AWS credentials have sufficient permissions
3. **Health check failures**: Check that the application is running on port 8080 inside the instances
4. **Database connection issues**: Verify security groups allow traffic between web and database tiers

### Logs

To check application logs on EC2 instances:

```bash
# SSH to instance
ssh -i dev-keypair.pem ubuntu@<INSTANCE_IP>

# Check application service status
sudo systemctl status webapp

# Check application logs
sudo journalctl -u webapp -f

# Check Flask application logs directly
sudo journalctl -u webapp -n 50
```

## Customization

### Scaling
Modify the auto scaling parameters in `terraform.tfvars`:
```hcl
asg_min_size         = 1
asg_max_size         = 5
asg_desired_capacity = 3
```

### Instance Size
Change the instance type in `terraform.tfvars`:
```hcl
instance_type = "t3.small"  # or any other instance type
```

### Database Configuration
Modify database settings in `terraform.tfvars`:
```hcl
db_instance_class   = "db.t3.small"
db_allocated_storage = 50
```

## Security Considerations

- Change the default database password in `terraform.tfvars`
- Consider using AWS Secrets Manager for sensitive data
- Enable HTTPS with SSL/TLS certificates for production
- Implement proper backup and disaster recovery procedures
- Use IAM roles and policies following the principle of least privilege
