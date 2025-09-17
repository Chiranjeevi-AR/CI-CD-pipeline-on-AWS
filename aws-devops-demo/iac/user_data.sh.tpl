#!/bin/bash
set -euxo pipefail

# Create detailed log file
exec > >(tee -a /var/log/user-data.log)
exec 2>&1

export DEBIAN_FRONTEND=noninteractive
echo "Starting deployment at $(date)"

# Update system
apt-get update -y
apt-get upgrade -y

# Install Node.js and git
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs git curl

# Install pm2 globally
npm install -g pm2

# Remove any existing app directory to ensure fresh deployment
rm -rf /home/ubuntu/app-repo

# Clone the repository with the latest code
cd /home/ubuntu
echo "Cloning repository: ${REPO_URL}"
git clone ${REPO_URL} app-repo
chown -R ubuntu:ubuntu /home/ubuntu/app-repo

# Navigate to app directory and install dependencies
cd /home/ubuntu/app-repo/aws-devops-demo/app
echo "Installing npm dependencies..."
sudo -u ubuntu npm install

# Verify files exist
echo "Checking application files:"
ls -la
ls -la views/ || echo "Views directory not found"
ls -la public/ || echo "Public directory not found"

# Stop any existing pm2 processes
sudo -u ubuntu pm2 delete all || true

# Start the app with pm2
echo "Starting application with pm2..."
sudo -u ubuntu PM2_HOME=/home/ubuntu/.pm2 pm2 start index.js --name "portfolio-app"
sudo -u ubuntu PM2_HOME=/home/ubuntu/.pm2 pm2 save

# Setup pm2 startup
sudo -u ubuntu PM2_HOME=/home/ubuntu/.pm2 pm2 startup systemd -u ubuntu --hp /home/ubuntu
sudo env PATH=$PATH:/usr/bin PM2_HOME=/home/ubuntu/.pm2 /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu

# Enable pm2 to start on boot
sudo systemctl enable pm2-ubuntu || true

# Wait for app to start
sleep 10

# Test the application
echo "Testing application endpoints:"
curl -f http://localhost:${PORT}/ || echo "Root endpoint failed"
curl -f http://localhost:${PORT}/health || echo "Health endpoint failed"
curl -f http://localhost:${PORT}/projects || echo "Projects endpoint failed"
curl -f http://localhost:${PORT}/contact || echo "Contact endpoint failed"

# Log final status
echo "Deployment completed at $(date)" >> /var/log/deployment.log
sudo -u ubuntu PM2_HOME=/home/ubuntu/.pm2 pm2 list >> /var/log/deployment.log
echo "Application should be accessible at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):${PORT}"


