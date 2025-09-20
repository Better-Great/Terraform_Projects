# Compute Module

## What This Module Does

This module creates all the compute resources that run your web application - the servers, load balancer, and auto-scaling setup. Think of it as setting up a fleet of web servers that automatically adjust based on traffic, with a smart load balancer directing users to healthy servers.

## What Gets Created

### 🌐 **Application Load Balancer (ALB)**
- **Purpose**: Distributes incoming web traffic across multiple servers
- **Type**: Application Load Balancer (smart routing for web apps)
- **Placement**: Public subnets (accessible from internet)
- **Health Checks**: Automatically removes unhealthy servers from rotation

### 🖥️ **EC2 Instances (Web Servers)**
- **Type**: t3.micro (1 vCPU, 1GB RAM - good for development)
- **Operating System**: Ubuntu 22.04 LTS (latest stable)
- **Location**: Private subnets (hidden from direct internet access)
- **Auto Scaling**: Automatically creates/destroys servers based on demand

### 🚀 **Launch Template**
- **Blueprint**: Defines how new servers should be configured
- **User Data Script**: Automatically installs and configures your web application
- **Security Groups**: Applies firewall rules to new instances

### 📈 **Auto Scaling Group (ASG)**
- **Min Size**: 1 server (always at least one running)
- **Max Size**: 5 servers (can scale up during high traffic)
- **Desired**: 2 servers (normal operation)
- **Health Checks**: Replaces unhealthy servers automatically

### 🎯 **Target Group**
- **Purpose**: Groups servers for the load balancer
- **Health Check**: Checks `/health` endpoint every 30 seconds
- **Protocol**: HTTP on port 8080 (where Flask runs)

### 📊 **CloudWatch Alarms & Auto Scaling Policies**
- **Scale Up**: Adds servers when CPU > 70% for 2 minutes
- **Scale Down**: Removes servers when CPU < 25% for 2 minutes
- **Cooldown**: Waits 5 minutes between scaling actions

### 🔑 **SSH Key Pair**
- **Purpose**: Allows secure access to servers for troubleshooting
- **Private Key**: Saved locally as `dev-keypair.pem`

## How Your Application Gets Deployed

### 📦 **Automatic Deployment Process** (via user_data.sh)
1. **System Setup**: Updates Ubuntu and installs Python, pip, git
2. **Code Deployment**: Clones your GitHub repository
3. **Environment Configuration**: Creates `.env` file with database credentials
4. **Dependencies**: Sets up Python virtual environment and installs requirements
5. **Service Setup**: Creates systemd service for automatic startup
6. **Health Check**: Adds `/health` endpoint for load balancer monitoring

### 🔄 **What Happens When Instance Starts**
```bash
# System updates and package installation
apt-get update -y
apt-get install -y python3 python3-pip python3-venv git

# Clone your application code
git clone https://github.com/Better-Great/Terraform_Projects.git

# Create environment configuration
cat > .env << EOF
DB_HOST=<database-endpoint>
DB_NAME=webappdb
DB_USERNAME=postgres
DB_PASSWORD=DevPassword123!
DB_PORT=5432
EOF

# Install Python dependencies
python3 -m venv venv
pip install flask psycopg2-binary bcrypt python-dotenv

# Start application as system service
systemctl start webapp.service
```

## Traffic Flow

### 🌍 **User Request Journey**
```
Internet User → Load Balancer → Healthy Web Server → Database → Response Back
```

1. **User visits your website**
2. **Load balancer receives request** (on port 80)
3. **Load balancer picks a healthy server** (based on health checks)
4. **Web server processes request** (Flask app on port 8080)
5. **Server queries database** (if needed)
6. **Response sent back to user**

### 🏥 **Health Monitoring**
- **Load Balancer Health Check**: GET `/health` every 30 seconds
- **Auto Scaling Health Check**: EC2 instance status + ELB health
- **Unhealthy Instance**: Automatically terminated and replaced

## Auto Scaling Behavior

### 📊 **Scaling Triggers**
- **Scale Up When**: Average CPU > 70% across all instances
- **Scale Down When**: Average CPU < 25% across all instances
- **Evaluation Period**: 2 minutes of sustained high/low usage
- **Cooldown**: 5 minutes between scaling actions

### 🎯 **Scaling Scenarios**
- **Normal Traffic**: Runs 2 instances
- **High Traffic**: Can scale up to 5 instances
- **Low Traffic**: Scales down to 1 instance (minimum)
- **Server Failure**: Immediately replaces failed instances

## Security Features

### 🛡️ **Network Security**
- **Private Subnets**: Servers not directly accessible from internet
- **Security Groups**: Only allow necessary ports (8080 from ALB, 22 for SSH)
- **Load Balancer**: Acts as shield between internet and servers

### 🔐 **Access Control**
- **SSH Key**: Required for server access
- **IAM Roles**: Servers have minimal required permissions
- **Security Groups**: Firewall rules at instance level

## Files in This Module

- `main.tf` - Main resources (ALB, ASG, Launch Template)
- `user_data.sh` - Script that runs when new instances start
- `variables.tf` - Input parameters
- `output.tf` - Values provided to other modules

## Key Outputs

This module provides:
- **Load Balancer DNS Name**: Your application URL
- **Auto Scaling Group Name**: For monitoring and management
- **Security Group IDs**: Used by other modules

## Monitoring & Troubleshooting

### 📊 **CloudWatch Metrics**
- **Application Load Balancer**: Request count, response times, error rates
- **Auto Scaling Group**: Instance count, scaling activities
- **EC2 Instances**: CPU, memory, network usage

### 🔍 **Common Troubleshooting Commands**
```bash
# Check instance status
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names dev-asg

# Check load balancer health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# SSH into instance (if needed)
ssh -i dev-keypair.pem ubuntu@<instance-ip>

# Check application logs
sudo journalctl -u webapp.service -f
```

### 🚨 **Common Issues & Solutions**
- **502 Bad Gateway**: Application not responding (check service logs)
- **Unhealthy Targets**: Health check failing (check `/health` endpoint)
- **Scaling Issues**: Check CloudWatch alarms and scaling policies

## Cost Optimization

### 💰 **Development Costs**
- **Instance Type**: t3.micro (eligible for free tier)
- **Min Instances**: 1 (saves money during low usage)
- **Auto Scaling**: Only pays for what you use

### 📈 **Production Recommendations**
- **Instance Type**: t3.small or larger for better performance
- **Min Instances**: 2+ for high availability
- **Monitoring**: Set up detailed CloudWatch monitoring
- **Reserved Instances**: For predictable workloads

## Application Features

### 🌟 **Your Flask Application Includes**
- **User Registration**: Form to create new users
- **Data Retrieval**: Search users by ID
- **User Management**: View and delete user records
- **Health Monitoring**: `/health` endpoint for load balancer
- **Database Integration**: Automatic table creation and data persistence

### 🔧 **Built-in Resilience**
- **Database Retry Logic**: Handles temporary connection issues
- **Graceful Failures**: Application continues even if database is temporarily unavailable
- **Automatic Restarts**: systemd automatically restarts failed application
- **Health Checks**: Load balancer removes unhealthy instances from rotation
