#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# Install Node.js and git
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs git

# Install pm2 globally
npm install -g pm2

# Clone the repository
cd /home/ubuntu
git clone ${REPO_URL} app-repo
chown -R ubuntu:ubuntu /home/ubuntu/app-repo

# Navigate to app directory and install dependencies
cd /home/ubuntu/app-repo/aws-devops-demo/app
sudo -u ubuntu npm install

# Start the app with pm2 and configure it to start on boot
sudo -u ubuntu pm2 start index.js --name "portfolio-app" -- --port=${PORT}
sudo -u ubuntu pm2 save
pm2 startup systemd -u ubuntu --hp /home/ubuntu
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu

# Enable pm2 to start on boot
sudo systemctl enable pm2-ubuntu

# Log the deployment status
echo "Application deployed successfully at $(date)" >> /var/log/deployment.log
curl -s http://localhost:${PORT}/health || echo "Health check failed" >> /var/log/deployment.log


