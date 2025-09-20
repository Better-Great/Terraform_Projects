# Database Module

## What This Module Does

This module creates a secure, managed PostgreSQL database in AWS RDS. Think of it as setting up a professional, highly-available data storage system that your web application can use to store user information, without you having to manage the database server yourself.

## What Gets Created

### 🗄️ **RDS PostgreSQL Database**
- **Engine**: PostgreSQL (open-source, powerful database)
- **Version**: Latest stable version
- **Instance**: db.t3.micro (good for development, can be upgraded)
- **Storage**: 20GB (can grow automatically as needed)

### 🏠 **Database Subnet Group**
- Groups the database subnets together
- Ensures database is placed in the right network locations
- Spreads across multiple availability zones for reliability

### ⚙️ **Parameter Group**
- Custom configuration settings for PostgreSQL
- Optimized for your application's needs
- Can be adjusted for performance tuning

### 🔐 **Security Features**
- **Private Subnets Only**: Database cannot be accessed from internet
- **Security Group Protection**: Only web servers can connect
- **Encrypted Storage**: Data is encrypted at rest
- **Backup Enabled**: Automatic daily backups
- **Multi-AZ Option**: Can run in multiple zones for high availability

## Database Configuration

### 📊 **Connection Details**
- **Database Name**: `webappdb`
- **Username**: `postgres` (PostgreSQL default admin user)
- **Password**: Set in `terraform.tfvars` (currently: `DevPassword123!`)
- **Port**: `5432` (PostgreSQL standard port)

### 🏗️ **What Tables Get Created**
When your web application starts, it creates this table:
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255), 
    address TEXT,
    phonenumber VARCHAR(255),
    password VARCHAR(255)  -- Encrypted with BCrypt
);
```

## How Your App Connects

### 🔌 **Connection Process**
1. Web application loads database credentials from `.env` file
2. Uses PostgreSQL connection library (psycopg2) to connect
3. Database endpoint is passed from Terraform (without port number)
4. Port is passed separately to avoid connection issues

### 🛡️ **Security Flow**
```
Web Server (Private Subnet) → Security Group Check → Database (Database Subnet)
```

Only web servers with the correct security group can reach the database.

## Backup & Maintenance

### 💾 **Automatic Backups**
- **Backup Window**: 3:00-4:00 AM UTC (low traffic time)
- **Retention**: 7 days of backups kept
- **Point-in-time Recovery**: Can restore to any second within backup period

### 🔧 **Maintenance**
- **Maintenance Window**: Sunday 4:00-5:00 AM UTC
- **Auto Minor Version Upgrades**: Enabled (security patches applied automatically)

## Environment-Specific Settings

### 🧪 **Development Environment**
- **Single AZ**: Saves money (not highly available)
- **No Deletion Protection**: Easy to destroy for testing
- **Skip Final Snapshot**: Faster cleanup

### 🏭 **Production Environment** (when you create it)
- **Multi-AZ**: High availability across zones
- **Deletion Protection**: Prevents accidental deletion
- **Final Snapshot**: Creates backup before deletion

## Files in This Module

- `main.tf` - Creates RDS instance and related resources
- `variables.tf` - Input parameters (instance size, passwords, etc.)
- `output.tf` - Database connection details for other modules

## Key Outputs

This module provides these values to other modules:
- **Database Endpoint**: Where to connect (hostname only)
- **Database Address**: Same as endpoint (for clarity)
- **Database Name**: `webappdb`
- **Username**: `postgres` 
- **Password**: From your configuration
- **Port**: `5432`

## Cost Optimization

### 💰 **Development Costs**
- Uses smallest instance size (db.t3.micro)
- Single AZ deployment
- Minimal storage (20GB, grows as needed)

### 📈 **Scaling Options**
- Can upgrade instance size without downtime
- Storage grows automatically
- Can enable Multi-AZ for production
- Read replicas can be added for heavy read workloads

## Monitoring

The database includes:
- **CloudWatch Metrics**: CPU, memory, connections, etc.
- **Enhanced Monitoring**: Detailed OS-level metrics
- **Logs**: Error logs, slow query logs
- **Events**: Notifications for maintenance, failures, etc.

## Common Operations

### 🔍 **To Check Database Status**
```bash
aws rds describe-db-instances --db-instance-identifier dev-database
```

### 🔌 **To Connect Directly** (for troubleshooting)
```bash
psql -h <endpoint> -U postgres -d webappdb
```

### 📊 **To View Logs**
```bash
aws rds describe-db-log-files --db-instance-identifier dev-database
```
