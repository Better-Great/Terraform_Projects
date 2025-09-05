#!/bin/bash

# Multi-Environment ASG Deployment Script
# This script helps deploy the infrastructure in the correct order

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command_exists terraform; then
    print_error "Terraform is not installed. Please install Terraform >= 1.0"
    exit 1
fi

if ! command_exists aws; then
    print_error "AWS CLI is not installed. Please install AWS CLI"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    print_error "AWS credentials not configured. Please run 'aws configure'"
    exit 1
fi

print_success "Prerequisites check passed"

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Step 1: Deploy remote backend
print_status "Step 1: Deploying remote backend infrastructure..."
cd "$SCRIPT_DIR/remote-backend"

terraform init
terraform plan -out=backend.tfplan
print_warning "Review the plan above. Press Enter to continue or Ctrl+C to cancel..."
read -r

terraform apply backend.tfplan
rm -f backend.tfplan

# Capture outputs
DEV_BUCKET=$(terraform output -raw dev_bucket_name)
PROD_BUCKET=$(terraform output -raw prod_bucket_name)
DYNAMODB_TABLE=$(terraform output -raw dynamodb_table_name)

print_success "Remote backend created successfully!"
print_status "Dev bucket: $DEV_BUCKET"
print_status "Prod bucket: $PROD_BUCKET"
print_status "DynamoDB table: $DYNAMODB_TABLE"

# Step 2: Update backend configuration
print_status "Step 2: Updating backend configuration..."

# Create backend configuration for dev environment
DEV_BACKEND_FILE="$SCRIPT_DIR/environments/dev/backend.tf"
if [[ -f "$SCRIPT_DIR/environments/dev/backend.tf.template" ]]; then
    sed "s/BUCKET_NAME_PLACEHOLDER/$DEV_BUCKET/g" "$SCRIPT_DIR/environments/dev/backend.tf.template" > "$DEV_BACKEND_FILE"
    print_status "Created dev backend configuration with bucket: $DEV_BUCKET"
fi

# Create backend configuration for prod environment  
PROD_BACKEND_FILE="$SCRIPT_DIR/environments/prod/backend.tf"
if [[ -f "$SCRIPT_DIR/environments/prod/backend.tf.template" ]]; then
    sed "s/BUCKET_NAME_PLACEHOLDER/$PROD_BUCKET/g" "$SCRIPT_DIR/environments/prod/backend.tf.template" > "$PROD_BACKEND_FILE"
    print_status "Created prod backend configuration with bucket: $PROD_BUCKET"
fi

print_success "Backend configuration updated"

# Step 3: Deploy environment
ENVIRONMENT=${1:-dev}
print_status "Step 3: Deploying $ENVIRONMENT environment..."

if [[ ! -d "$SCRIPT_DIR/environments/$ENVIRONMENT" ]]; then
    print_error "Environment '$ENVIRONMENT' not found. Available: dev, prod"
    exit 1
fi

cd "$SCRIPT_DIR/environments/$ENVIRONMENT"

terraform init
terraform plan -out=env.tfplan
print_warning "Review the plan above. Press Enter to continue or Ctrl+C to cancel..."
read -r

terraform apply env.tfplan
rm -f env.tfplan

# Display outputs
print_success "Deployment completed successfully!"
echo ""
print_status "Application URL: $(terraform output -raw application_url)"
print_status "ALB DNS Name: $(terraform output -raw alb_dns_name)"
print_status "Environment: $(terraform output -raw environment)"
print_status "Region: $(terraform output -raw region)"

echo ""
print_status "SSH Key: The private key has been saved as '${ENVIRONMENT}-keypair.pem' in the current directory"
print_warning "Make sure to secure the key file: chmod 600 ${ENVIRONMENT}-keypair.pem"

echo ""
print_success "Deployment complete! You can now access your application at the URL above."
print_status "It may take a few minutes for the instances to be ready and pass health checks."
