# Networking Module

## What This Module Does

This module creates all the networking infrastructure needed for a secure 3-tier web application in AWS. Think of it as building the "roads and neighborhoods" where your application will live.

## What Gets Created

### 🏘️ **Virtual Private Cloud (VPC)**
- Creates your own private network in AWS (like your own neighborhood)
- Uses IP range: 10.0.0.0/16 (gives you lots of room for growth)

### 🛣️ **Subnets (Different Areas)**
1. **Public Subnets** (2 subnets across 2 availability zones)
   - Where the load balancer lives
   - Can access the internet directly
   - IP ranges: 10.0.1.0/24, 10.0.2.0/24

2. **Private Subnets** (2 subnets across 2 availability zones) 
   - Where your web servers live
   - Cannot be accessed directly from internet (more secure)
   - Can access internet through NAT Gateway
   - IP ranges: 10.0.3.0/24, 10.0.4.0/24

3. **Database Subnets** (2 subnets across 2 availability zones)
   - Where your database lives
   - Completely isolated from internet
   - Only accessible by your web servers
   - IP ranges: 10.0.5.0/24, 10.0.6.0/24

### 🌐 **Internet Access**
- **Internet Gateway**: Allows public subnets to access internet
- **NAT Gateway**: Allows private subnets to access internet securely (for updates, etc.)

### 🛡️ **Security Groups (Firewalls)**
1. **Load Balancer Security Group**
   - Allows web traffic (HTTP port 80) from anywhere on internet
   
2. **Web Server Security Group**  
   - Allows traffic from load balancer on port 8080
   - Allows SSH access (port 22) for management
   
3. **Database Security Group**
   - Only allows database traffic (port 5432) from web servers
   - No internet access at all

### 🚦 **Network Access Control Lists (NACLs)**
- Additional security layer that controls traffic at subnet level
- Like having security guards at neighborhood entrances

## Why This Design?

### 🔒 **Security**
- Web servers are hidden in private subnets
- Database is completely isolated
- Only necessary ports are open
- Multiple layers of security (Security Groups + NACLs)

### 🏗️ **High Availability** 
- Everything is spread across 2 availability zones
- If one zone fails, the other keeps running

### 📈 **Scalability**
- Plenty of IP addresses for growth
- Easy to add more subnets or resources

## How It Works Together

```
Internet → Load Balancer (Public Subnet) → Web Servers (Private Subnet) → Database (Database Subnet)
```

1. Users access your website through the internet
2. Load balancer receives requests and distributes them
3. Web servers process requests and query database if needed
4. Database stores and retrieves data
5. Response flows back to user

## Files in This Module

- `main.tf` - Creates VPC and subnets
- `security-group.tf` - Creates all security groups  
- `nacls.tf` - Creates network access control lists
- `route-table.tf` - Creates routing rules
- `variables.tf` - Input parameters
- `output.tf` - Values other modules can use

## Key Outputs

This module provides these values to other modules:
- VPC ID
- Subnet IDs (public, private, database)
- Security Group IDs
- Route Table IDs

Other modules use these to know where to place resources and how to connect them securely.
