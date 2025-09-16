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

cd "$APP_DIR"

cat > index.js <<'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from AWS DevOps Pipeline 🚀');
});

app.get('/health', (_req, res) => {
  res.status(200).send('OK');
});

app.listen(PORT, () => {
  console.log(`App running on http://localhost:${PORT}`);
});
EOF

cat > package.json <<'EOF'
{
  "name": "aws-devops-demo",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "echo \"No tests yet\" && exit 0"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

npm install --omit=dev || true

pm2 delete aws-devops-demo || true
PORT=3000 pm2 start index.js --name aws-devops-demo --update-env --env-production
pm2 save || true
pm2 startup systemd -u ubuntu --hp /home/ubuntu || true


