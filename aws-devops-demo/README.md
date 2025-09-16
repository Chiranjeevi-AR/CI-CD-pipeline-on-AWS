# AWS DevOps Demo Assignment

This repository demonstrates a production-ready CI/CD pipeline deploying a Node.js app to AWS EC2 using Terraform and GitHub Actions. It follows IaC best practices and uses GitHub Secrets for credentials.

## Repository Structure

```
aws-devops-demo/
│── app/              # Node.js Express app
│── iac/              # Terraform IaC for EC2 + SG + user_data
│── pipeline/         # GitHub Actions workflow
│── .gitignore
│── README.md
```

## Application
- Simple Express server listening on port 3000
- Root path `/` responds: "Hello from AWS DevOps Pipeline 🚀"
- Health check at `/health`

## Prerequisites
- AWS Account with an IAM user (programmatic access) with permissions for EC2, VPC, and IAM read-only
- An EC2 Key Pair in `ap-south-1` (Mumbai)
- GitHub repository with the following Secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_KEY_PAIR_NAME` (name of the EC2 key pair)

## Setup Steps
1. Fork or push this repo to your GitHub account.
2. Create an IAM user with programmatic access and attach a policy that allows EC2/VPC operations (e.g., `AmazonEC2FullAccess` for demo; least privilege recommended in production).
3. In your GitHub repo Settings → Secrets and variables → Actions, add:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_KEY_PAIR_NAME`
4. Ensure you have a Key Pair created in AWS EC2 (Mumbai `ap-south-1`).

## Local Run (optional)
```
cd aws-devops-demo/app
npm install
npm start
```
Visit `http://localhost:3000`.

## CI/CD Workflow
- Trigger: push to `main`
- Jobs:
  - Install and test Node app
  - Configure AWS credentials
  - Terraform init/validate/apply in `ap-south-1`, passing `repo_url` and `key_name`

## Terraform IaC
- Provisions a `t2.micro` Ubuntu 22.04 EC2 instance in default VPC/subnet in `ap-south-1`
- Security Group allows inbound 22 (SSH from `ssh_cidr`) and 3000 (from anywhere)
- `user_data` installs Node.js, clones this repository, installs dependencies, and starts the app with `pm2`
- Outputs the instance `public_ip`

Apply manually if needed:
```
cd aws-devops-demo/iac
terraform init
terraform apply -auto-approve \
  -var "repo_url=https://github.com/<your-org>/<your-repo>.git" \
  -var "key_name=<your-key-pair-name>" \
  -var "aws_region=ap-south-1"
```

## Verify Deployment
- After the workflow completes, find the `public_ip` output in the Terraform logs or the state.
- Open: `http://<EC2_PUBLIC_IP>:3000/` → should display: "Hello from AWS DevOps Pipeline 🚀"
- Health check: `http://<EC2_PUBLIC_IP>:3000/health`

## Improvements
- Use an Application Load Balancer and Auto Scaling Group
- Containerize app and run on ECS/Fargate or EKS
- Add monitoring/alerts (CloudWatch, Prometheus/Grafana)
- Blue/Green or Canary deployments (CodeDeploy, ALB weighted routing)
- Use SSM Parameter Store/Secrets Manager for config and secrets

## Security Notes
- All credentials are sourced from GitHub Secrets; no hard-coded secrets
- Restrict `ssh_cidr` to your IP instead of `0.0.0.0/0` for production
