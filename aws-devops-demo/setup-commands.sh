#!/bin/bash
# Commands to run on EC2 instance one by one

echo "Step 1: Install pm2"
sudo npm install -g pm2

echo "Step 2: Create app directory"
sudo mkdir -p /opt/aws-devops-demo/app
cd /opt/aws-devops-demo/app

echo "Step 3: Create index.js"
sudo tee index.js > /dev/null <<'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from AWS DevOps Pipeline 🚀');
});

app.listen(PORT, () => {
  console.log(`App running on http://localhost:${PORT}`);
});
EOF

echo "Step 4: Create package.json"
sudo tee package.json > /dev/null <<'EOF'
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

echo "Step 5: Install dependencies"
sudo npm install

echo "Step 6: Start with pm2"
sudo pm2 start index.js --name aws-devops-demo
sudo pm2 save

echo "Step 7: Test the app"
curl http://localhost:3000

echo "Done! Check http://<EC2_PUBLIC_IP>:3000 in your browser"
