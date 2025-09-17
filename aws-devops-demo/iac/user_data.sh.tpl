#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# Install Node.js and git
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs git

# Clone the repository
cd /home/ubuntu
git clone ${REPO_URL} app-repo

# Navigate to app directory and install dependencies
cd /home/ubuntu/app-repo/aws-devops-demo/app
npm install

# Start the app with nohup and log to /var/log/app.log
nohup npm start > /var/log/app.log 2>&1 &


