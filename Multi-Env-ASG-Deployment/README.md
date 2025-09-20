# Multi-Environment Auto Scaling 3-Tier Web Application

A complete, production-ready infrastructure setup that deploys a 3-tier user management web application using Terraform, with automatic scaling, load balancing, and database integration.

## 🎯 What This Project Achieves

This project creates a **complete web application infrastructure** that automatically:
- **Deploys your Flask web application** from GitHub
- **Scales servers up/down** based on traffic
- **Balances load** across multiple servers
- **Stores data** in a secure PostgreSQL database
- **Monitors health** and replaces failed components
- **Provides high availability** across multiple AWS zones

## 🏗️ Architecture Overview

```
Internet Users
     ↓
🌐 Application Load Balancer (Public Subnets)
     ↓
🖥️ Web Servers (Private Subnets) - Auto Scaling Group
     ↓
🗄️ PostgreSQL Database (Database Subnets) - RDS
```

### **3-Tier Architecture Explained**

1. **🌐 Presentation Tier**: Load balancer and web interface
2. **🖥️ Application Tier**: Flask web servers running your business logic
3. **🗄️ Data Tier**: PostgreSQL database storing user information

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform installed (v1.0+)
- Git access to this repository

### Deploy in 3 Steps

1. **Navigate to environment**
   ```bash
   cd environments/dev
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Deploy everything**
   ```bash
   terraform apply
   ```

That's it! Your complete web application infrastructure will be ready in ~10 minutes.

## 🌍 Your Live Application

After deployment, you'll get:
- **Application URL**: `http://dev-alb-xxxxxxxxx.us-east-1.elb.amazonaws.com`
- **Features Available**:
  - User registration form
  - User data retrieval by ID
  - User management (view/delete)
  - Automatic data persistence

## 📁 Project Structure

```
Multi-Env-ASG-Deployment/
├── modules/                    # Reusable Terraform modules
│   ├── networking/            # VPC, subnets, security groups
│   ├── database/              # RDS PostgreSQL setup
│   └── compute/               # Load balancer, auto scaling, EC2
├── environments/              # Environment-specific configurations
│   └── dev/                   # Development environment
├── 3-tier-user-management-app/ # Your Flask web application
└── deploy.sh                  # Automated deployment script
```

## 🔧 Modules Explained

### 🌐 [Networking Module](modules/networking/README.md)
Creates secure network infrastructure:
- **VPC** with public, private, and database subnets
- **Security groups** controlling access between tiers
- **NAT Gateway** for secure internet access
- **Route tables** directing network traffic

### 🗄️ [Database Module](modules/database/README.md)
Sets up managed PostgreSQL database:
- **RDS PostgreSQL** instance with automatic backups
- **Multi-AZ** deployment for high availability
- **Security groups** allowing only web server access
- **Parameter groups** optimized for your application

### 🖥️ [Compute Module](modules/compute/README.md)
Creates scalable web application infrastructure:
- **Application Load Balancer** distributing traffic
- **Auto Scaling Group** managing server count
- **Launch Template** defining server configuration
- **CloudWatch Alarms** triggering scaling actions

## ⚙️ Configuration

### Environment Variables (terraform.tfvars)
```hcl
# Application Settings
app_port = 8080

# Database Configuration  
db_name     = "webappdb"
db_username = "postgres"
db_password = "DevPassword123!"  # Change for production!

# Infrastructure Sizing
instance_type           = "t3.micro"
asg_min_size           = 1
asg_max_size           = 5
asg_desired_capacity   = 2
```

### Key Features Configured
- **Auto Scaling**: 1-5 instances based on CPU usage
- **Health Checks**: Automatic replacement of failed servers
- **Security**: Multi-layered security groups and NACLs
- **Monitoring**: CloudWatch metrics and alarms
- **Backups**: Automatic database backups

## 🔒 Security Features

### Network Security
- **Private Subnets**: Web servers hidden from direct internet access
- **Database Isolation**: Database in dedicated subnets
- **Security Groups**: Firewall rules at instance level
- **NACLs**: Additional subnet-level security

### Application Security
- **Password Hashing**: BCrypt encryption for user passwords
- **Environment Variables**: Sensitive data in `.env` files
- **SQL Injection Protection**: Parameterized database queries
- **HTTPS Ready**: Easy to add SSL certificates

## 📊 Monitoring & Operations

### Built-in Monitoring
- **Application Load Balancer**: Request metrics, error rates
- **Auto Scaling**: Instance count, scaling activities
- **Database**: Connection count, CPU usage, storage
- **Health Checks**: Automatic unhealthy instance replacement

### Operational Commands
```bash
# Check application status
terraform output application_url

# View auto scaling activity
aws autoscaling describe-scaling-activities --auto-scaling-group-name dev-asg

# Check database status
aws rds describe-db-instances --db-instance-identifier dev-database

# SSH to instance (if needed)
ssh -i dev-keypair.pem ubuntu@<instance-ip>
```

## 💰 Cost Optimization

### Development Environment
- **t3.micro instances**: Free tier eligible
- **Single AZ database**: Reduced costs
- **Auto scaling**: Pay only for what you use
- **Minimal storage**: 20GB database, grows as needed

### Estimated Monthly Costs (US-East-1)
- **EC2 instances**: $8-40 (depending on scaling)
- **RDS database**: $12-15
- **Load balancer**: $16-20
- **Data transfer**: $1-5
- **Total**: ~$37-80/month for development

## 🔄 Multi-Environment Support

This infrastructure supports multiple environments:

### Current: Development
- Single AZ for cost savings
- Smaller instance sizes
- Development database settings

### Future: Production
```bash
# Create production environment
cp -r environments/dev environments/prod
# Modify prod/terraform.tfvars for production settings
cd environments/prod
terraform init
terraform apply
```

## 🛠️ Application Details

### Your Flask Web Application
- **Framework**: Flask with modern HTML/CSS templates
- **Database**: PostgreSQL with automatic table creation
- **Features**: User registration, data retrieval, management
- **Deployment**: Automatic from GitHub repository
- **Health Monitoring**: Built-in health check endpoint

### Automatic Deployment Process
1. **Code Fetch**: Clones latest code from GitHub
2. **Environment Setup**: Creates Python virtual environment
3. **Dependencies**: Installs required packages
4. **Configuration**: Sets up database connection
5. **Service Creation**: Creates systemd service for reliability
6. **Health Checks**: Registers with load balancer

## 🔧 Troubleshooting

### Common Issues
1. **502 Bad Gateway**: Application not starting
   - Check: `journalctl -u webapp.service -f`
   
2. **Database Connection Failed**: Network or credentials issue
   - Check: Security groups and database credentials
   
3. **Auto Scaling Not Working**: CloudWatch alarms misconfigured
   - Check: CloudWatch metrics and alarm states

### Debug Commands
```bash
# Check service logs
sudo journalctl -u webapp.service -f

# Test database connection
curl http://localhost:8080/health

# Check auto scaling group
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names dev-asg
```

## 🎉 Success Indicators

When everything is working correctly, you should see:
- ✅ **Application URL** returns your web interface
- ✅ **User registration** successfully saves to database  
- ✅ **Data retrieval** shows stored user information
- ✅ **Auto scaling** responds to load changes
- ✅ **Health checks** show all targets healthy

## 📚 Further Learning

### Next Steps
1. **Add HTTPS**: Configure SSL certificates
2. **Custom Domain**: Route 53 DNS configuration
3. **CI/CD Pipeline**: Automated deployments
4. **Monitoring**: Enhanced CloudWatch dashboards
5. **Backup Strategy**: Cross-region backup setup

### Related AWS Services
- **Route 53**: DNS and domain management
- **CloudFront**: CDN for global performance
- **WAF**: Web application firewall
- **Secrets Manager**: Secure credential storage
- **Systems Manager**: Instance management

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Test your changes in dev environment
4. Submit pull request

## 📄 License

This project is open source and available under the MIT License.

---

## 🎯 Project Goals Achieved

✅ **Automated Infrastructure**: Complete infrastructure as code  
✅ **Scalable Architecture**: Auto scaling based on demand  
✅ **High Availability**: Multi-AZ deployment with health checks  
✅ **Security**: Multi-layered security implementation  
✅ **Cost Effective**: Optimized for development and production  
✅ **Production Ready**: Monitoring, backups, and operational tools  
✅ **Easy Deployment**: One-command infrastructure deployment  

**Result**: A professional, scalable web application infrastructure that automatically handles traffic, failures, and growth! 🚀
