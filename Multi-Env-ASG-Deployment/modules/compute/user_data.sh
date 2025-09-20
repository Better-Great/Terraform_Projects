#!/bin/bash

# Update system
apt-get update -y

# Install required packages
apt-get install -y python3 python3-pip python3-venv git

# Create application directory
mkdir -p /opt/webapp
cd /opt/webapp

# Clone the repository and copy the 3-tier application
git clone https://github.com/Better-Great/Terraform_Projects.git /tmp/repo

# Copy the 3-tier application to our working directory
cp -r /tmp/repo/Multi-Env-ASG-Deployment/3-tier-user-management-app/* /opt/webapp/

# Create .env file with database configuration from Terraform variables
cat > .env << EOF
# Database Configuration from Terraform
DB_HOST=${db_host}
DB_NAME=${db_name}
DB_USERNAME=${db_username}
DB_PASSWORD=${db_password}
DB_PORT=${db_port}

# Flask Configuration for Production
FLASK_ENV=production
FLASK_DEBUG=False

# Security
SECRET_KEY=terraform-deployed-app-$(date +%s)
EOF

# Add health check endpoint to the existing app.py
cat >> app.py << 'EOF'

@app.route('/health')
def health_check():
    return {'status': 'healthy', 'service': 'user-management-app'}, 200
EOF

# Update the app.py to use environment variables and make it more resilient
sed -i "s/app.run(debug=True, port=8080, host='0.0.0.0')/app.run(debug=False, port=${app_port}, host='0.0.0.0')/" app.py

# Create virtual environment and install dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create systemd service file
cat << EOF > /etc/systemd/system/webapp.service
[Unit]
Description=Flask User Management Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/webapp
Environment=PATH=/opt/webapp/venv/bin
EnvironmentFile=/opt/webapp/.env
ExecStart=/opt/webapp/venv/bin/python app.py
Restart=always
RestartSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Change ownership to ubuntu user
chown -R ubuntu:ubuntu /opt/webapp

# Enable and start the service
systemctl daemon-reload
systemctl enable webapp.service
systemctl start webapp.service

# Wait for service to start
sleep 15

# Check service status
systemctl status webapp.service --no-pager -l

# Clean up
rm -rf /tmp/repo

echo "3-tier application deployment completed!"
echo "Service status: $(systemctl is-active webapp.service)"
echo "Application should be running on port ${app_port}"