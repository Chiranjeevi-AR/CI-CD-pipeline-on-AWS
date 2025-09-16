#!/bin/bash
set -euxo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs git unzip
npm install -g pm2

APP_DIR=/opt/aws-devops-demo/app
mkdir -p "$APP_DIR"

if [ ! -d "$APP_DIR/node_modules" ]; then
  git clone ${REPO_URL} /opt/aws-devops-demo/repo
  cp -r /opt/aws-devops-demo/repo/aws-devops-demo/app/* "$APP_DIR"/
fi

cd "$APP_DIR"
npm install --omit=dev || true

pm2 delete aws-devops-demo || true
PORT=3000 pm2 start index.js --name aws-devops-demo --update-env --env-production
pm2 save || true
pm2 startup systemd -u ubuntu --hp /home/ubuntu || true


