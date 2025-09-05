#!/bin/bash

# Backend Configuration Helper Script
# This script helps configure the backend after remote backend creation

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_status "Backend Configuration Helper"
print_status "============================="

# Check if remote backend has been deployed
if [[ ! -d "$SCRIPT_DIR/remote-backend/.terraform" ]]; then
    print_error "Remote backend not deployed. Please run 'terraform apply' in the remote-backend directory first."
    exit 1
fi

# Get outputs from remote backend
cd "$SCRIPT_DIR/remote-backend"

if ! terraform output dev_bucket_name >/dev/null 2>&1; then
    print_error "Cannot get remote backend outputs. Make sure remote backend is deployed."
    exit 1
fi

DEV_BUCKET=$(terraform output -raw dev_bucket_name)
PROD_BUCKET=$(terraform output -raw prod_bucket_name)
DYNAMODB_TABLE=$(terraform output -raw dynamodb_table_name)

print_status "Retrieved backend configuration:"
print_status "Dev bucket: $DEV_BUCKET"
print_status "Prod bucket: $PROD_BUCKET"
print_status "DynamoDB table: $DYNAMODB_TABLE"

# Configure environments
ENVIRONMENTS=("dev" "prod")

for env in "${ENVIRONMENTS[@]}"; do
    ENV_DIR="$SCRIPT_DIR/environments/$env"
    TEMPLATE_FILE="$ENV_DIR/backend.tf.template"
    BACKEND_FILE="$ENV_DIR/backend.tf"
    
    if [[ -f "$TEMPLATE_FILE" ]]; then
        if [[ "$env" == "dev" ]]; then
            BUCKET_NAME="$DEV_BUCKET"
        else
            BUCKET_NAME="$PROD_BUCKET"
        fi
        
        sed "s/BUCKET_NAME_PLACEHOLDER/$BUCKET_NAME/g" "$TEMPLATE_FILE" > "$BACKEND_FILE"
        print_success "Created $env backend configuration"
    else
        print_warning "Template file not found: $TEMPLATE_FILE"
    fi
done

print_success "Backend configuration completed!"
print_status ""
print_status "Next steps:"
print_status "1. cd environments/dev (or prod)"
print_status "2. terraform init"
print_status "3. terraform plan"
print_status "4. terraform apply"
