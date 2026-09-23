# Sameed E-Commerce Platform — AWS Infrastructure with Terraform

<p align="center">
  <img src="assets/website-preview.jpg" alt="Sameed E-Commerce Platform website preview" width="900">
</p>

<p align="center">
  <strong>Multi-tier AWS e-commerce application deployed with Terraform, Nginx, Python Flask, Amazon EC2, and Amazon RDS MySQL.</strong>
</p>

---

## 📌 Project Overview

This project demonstrates the deployment of a multi-tier e-commerce application on AWS using **Infrastructure as Code (IaC) with Terraform**.

The architecture separates the application into three logical tiers:

- **Frontend Tier** — Public Amazon EC2 instance running Nginx
- **Application Tier** — Private Amazon EC2 instance running Python Flask with PM2
- **Database Tier** — Private Amazon RDS MySQL database

The frontend receives requests from internet users, Nginx forwards API requests to the private backend through the VPC, and the backend communicates with the private RDS database.

## 🏗️ Architecture

```text
                           INTERNET
                              |
                              | HTTP :80
                              v
                  +-------------------------+
                  |      FRONTEND EC2       |
                  |          Nginx          |
                  |      Public Subnet      |
                  +-------------------------+
                              |
                              | VPC Private Network
                              | TCP :5000
                              v
                  +-------------------------+
                  |       BACKEND EC2       |
                  |    Python Flask + PM2   |
                  |      Private Subnet     |
                  +-------------------------+
                              |
                              | TCP :3306
                              v
                  +-------------------------+
                  |       AMAZON RDS        |
                  |        MySQL DB         |
                  |    Private DB Subnets   |
                  +-------------------------+
```

## 🔐 Network & Security Design

Traffic is restricted between application tiers using AWS Security Groups:

```text
Internet
   |
   | :80
   v
Frontend Security Group
   |
   | :5000
   v
Backend Security Group
   |
   | :3306
   v
Database Security Group
```

### Security model

- Frontend EC2 is publicly reachable on **HTTP port 80**
- SSH access to the frontend is restricted to the configured administrator CIDR
- Backend EC2 has **no public IP**
- Backend port **5000** accepts traffic only from the frontend Security Group
- RDS MySQL port **3306** accepts traffic only from the backend Security Group
- RDS is configured as **not publicly accessible**
- AWS Systems Manager can be used to manage the private backend instance

## ☁️ AWS Services

| Service | Purpose |
|---|---|
| **Amazon VPC** | Isolated cloud network |
| **Amazon EC2** | Hosts frontend and backend application tiers |
| **Amazon RDS MySQL** | Managed relational database |
| **Internet Gateway** | Internet connectivity for the public subnet |
| **NAT Gateway** | Outbound internet access for private resources |
| **Route Tables** | Control subnet traffic routing |
| **Security Groups** | Control inbound and outbound traffic |
| **IAM** | EC2 permissions and Systems Manager access |
| **AWS Systems Manager** | Secure management of the private EC2 |
| **Nginx** | Web server and reverse proxy |
| **PM2** | Process management for the Flask backend |

## 🧩 Application Components

### Frontend

The frontend is served by **Nginx** on the public EC2 instance.

Responsibilities:

- Serve static website files
- Accept HTTP traffic on port `80`
- Forward `/api` requests to the private Flask backend

### Backend

The application backend is a **Python Flask** service running on the private EC2 instance.

Responsibilities:

- Process application/API requests
- Communicate with the MySQL database
- Provide application logic and authentication-related functionality
- Run on port `5000`

PM2 can be used to keep the Flask process running.

### Database

The application uses **Amazon RDS for MySQL**.

Responsibilities:

- Store application data
- Provide managed MySQL database services
- Remain private inside the VPC

## 🛠️ Terraform Structure

```text
sameed-ecommerce-aws-terraform/
│
├── README.md
├── provider.tf
├── variables.tf
├── network.tf
├── security.tf
├── iam.tf
├── rds.tf
├── ec2.tf
├── outputs.tf
├── terraform.tfvars
└── .gitignore
```

### File Responsibilities

| File | Purpose |
|---|---|
| `provider.tf` | Terraform and AWS provider configuration |
| `variables.tf` | Input variables |
| `network.tf` | VPC, subnets, gateways, routes, and NAT |
| `security.tf` | Frontend, backend, and database Security Groups |
| `iam.tf` | IAM role and instance profile |
| `rds.tf` | RDS subnet group and MySQL database |
| `ec2.tf` | Frontend and backend EC2 instances |
| `outputs.tf` | Important infrastructure outputs |
| `terraform.tfvars` | Environment-specific variable values |
| `.gitignore` | Prevents secrets/state files from being committed |

## 🚀 Deployment Workflow

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Format the configuration

```bash
terraform fmt
```

### 3. Validate the configuration

```bash
terraform validate
```

### 4. Review the execution plan

```bash
terraform plan
```

### 5. Deploy the infrastructure

```bash
terraform apply
```

### 6. Remove the lab environment

```bash
terraform destroy
```

## 🔄 Application Request Flow

When a user opens the website:

```text
Browser
   |
   | HTTP :80
   v
Nginx on Frontend EC2
   |
   | /api → Backend Private IP :5000
   v
Flask Backend EC2
   |
   | MySQL :3306
   v
Amazon RDS MySQL
```

This design keeps the backend and database off the public internet while allowing the required application traffic between tiers.

## 🗄️ Database Configuration

The backend uses environment variables similar to:

```text
PORT=5000
DB_HOST=<RDS-ENDPOINT>
DB_USER=<DB-USER>
DB_PASSWORD=<DB-PASSWORD>
DB_NAME=cloud
```

SMTP variables can also be configured for application email/OTP functionality.

> ⚠️ **Security:** Never commit real database passwords, SMTP passwords, API keys, private keys, or other secrets to GitHub.

## ✅ Validation & Testing

The project includes validation of the main infrastructure and connectivity paths:

```text
Terraform
   ↓
AWS Infrastructure
   ↓
Frontend EC2
   ↓
Backend EC2
   ↓
RDS MySQL
```

Example backend health check:

```bash
curl http://127.0.0.1:5000/api
```

Example frontend-to-backend test:

```bash
curl http://<BACKEND_PRIVATE_IP>:5000/api
```

## 🎯 DevOps Skills Demonstrated

This project demonstrates practical knowledge of:

- Infrastructure as Code with Terraform
- AWS VPC architecture
- Public and private subnet design
- Route tables and routing
- Internet Gateway and NAT Gateway
- AWS Security Groups
- IAM roles and instance profiles
- EC2 provisioning
- Private EC2 management with AWS Systems Manager
- Nginx configuration
- Reverse proxy configuration
- Python Flask deployment
- PM2 process management
- Amazon RDS MySQL
- Application-to-database connectivity
- Linux administration
- Git and GitHub
- Environment-based application configuration
- Basic AWS troubleshooting

## 💼 Interview Project Description

### 60-Second Explanation

> **I built a multi-tier e-commerce application on AWS using Terraform as Infrastructure as Code. The frontend is deployed on a public EC2 instance running Nginx, while the Flask backend is deployed on a private EC2 instance. Amazon RDS MySQL is placed in private database subnets. I configured Security Groups so that internet traffic can reach only the frontend, the frontend can communicate with the backend on port 5000, and only the backend can access MySQL on port 3306. Nginx acts as a reverse proxy for API requests, and NAT Gateway provides outbound connectivity for private resources.**

## ❓ Key Interview Questions

### Why is the backend in a private subnet?

The backend does not need direct internet access from users. Keeping it private reduces direct exposure and allows traffic only from the frontend tier.

### Why is RDS private?

The database should not be directly reachable from the internet. Only the backend application needs database access.

### Why use a NAT Gateway?

The private backend may need outbound connectivity for package installation, software updates, repository access, and other external connections without assigning it a public IP.

### Why use Security Groups instead of opening ports to everyone?

Security Groups allow traffic to be restricted to specific application tiers. For example, backend port `5000` is allowed from the frontend Security Group rather than from the entire internet.

### Why use Nginx?

Nginx serves the frontend and acts as a reverse proxy that forwards `/api` requests to the private backend.

### Why use Terraform?

Terraform allows infrastructure to be defined as code, reviewed, version-controlled, reproduced, and managed consistently.

### How does the frontend communicate with the private backend?

The frontend uses the backend EC2's private IP address over the VPC network on port `5000`.

### How does the backend communicate with RDS?

The backend uses the private RDS endpoint over MySQL port `3306`, and the RDS Security Group permits access from the backend Security Group.

## 📊 Project Scope

This repository focuses on the original AWS architecture:

```text
Terraform
   ↓
VPC
   ↓
EC2 + Nginx
   ↓
Private EC2 + Flask
   ↓
Private RDS MySQL
```

Docker, Amazon ECR, ECS, EKS, Jenkins, and GitHub Actions are intentionally outside the scope of this implementation.

## ⚠️ Cost & Cleanup

Some AWS resources used in this project can generate charges, particularly:

- NAT Gateway
- Amazon RDS
- EC2

When the project is no longer needed, destroy the Terraform-managed infrastructure:

```bash
terraform destroy
```

Always verify in the AWS Console that the resources have been removed.

## 👨‍💻 Author

**Sameed Khan**

GitHub: `https://github.com/Sameedkhan469`

LinkedIn: `https://www.linkedin.com/in/sameed-khan-a6824538a`

---

⭐ This project is part of my hands-on Cloud & DevOps learning portfolio, focused on AWS infrastructure, Terraform, networking, Linux administration, and application deployment.
