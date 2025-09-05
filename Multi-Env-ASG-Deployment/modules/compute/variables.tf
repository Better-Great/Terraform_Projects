# Environment and Common
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# Networking
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EC2 instances"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "web_security_group_id" {
  description = "Security group ID for web servers"
  type        = string
}

# Application Load Balancer
variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 5000
}

# Health Check Configuration
variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/health"
}

variable "health_check_healthy_threshold" {
  description = "Health check healthy threshold"
  type        = number
  default     = 2
}

variable "health_check_interval" {
  description = "Health check interval"
  type        = number
  default     = 30
}

variable "health_check_matcher" {
  description = "Health check response matcher"
  type        = string
  default     = "200"
}

variable "health_check_timeout" {
  description = "Health check timeout"
  type        = number
  default     = 5
}

variable "health_check_unhealthy_threshold" {
  description = "Health check unhealthy threshold"
  type        = number
  default     = 2
}

variable "health_check_grace_period" {
  description = "ASG health check grace period"
  type        = number
  default     = 300
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "EC2 Key Pair name"
  type        = string
}

# Auto Scaling Configuration
variable "asg_min_size" {
  description = "ASG minimum size"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "ASG maximum size"
  type        = number
  default     = 6
}

variable "asg_desired_capacity" {
  description = "ASG desired capacity"
  type        = number
  default     = 2
}

# Scaling Policies
variable "scale_up_adjustment" {
  description = "Scale up adjustment"
  type        = number
  default     = 1
}

variable "scale_up_cooldown" {
  description = "Scale up cooldown"
  type        = number
  default     = 300
}

variable "scale_down_adjustment" {
  description = "Scale down adjustment"
  type        = number
  default     = -1
}

variable "scale_down_cooldown" {
  description = "Scale down cooldown"
  type        = number
  default     = 300
}

# CloudWatch Alarms
variable "high_cpu_threshold" {
  description = "High CPU threshold for scaling up"
  type        = number
  default     = 80
}

variable "low_cpu_threshold" {
  description = "Low CPU threshold for scaling down"
  type        = number
  default     = 20
}

# Database Connection (from database module)
variable "db_endpoint" {
  description = "Database endpoint"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}