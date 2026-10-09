# Project Overview: AWS Three-Tier Web Application Infrastructure

---

## 1. Executive Summary & Business Context

This project delivers a resilient, scalable, and modular **Three-Tier Web Application Infrastructure on Amazon Web Services (AWS)** provisioned entirely using **Terraform (Infrastructure as Code)**.

Modern digital applications require high availability, strict isolation of sensitive data, secure perimeter management, and seamless traffic distribution. This reference architecture implements enterprise-grade infrastructure principles by separating client-facing presentation logic, business application processing, and data persistence into distinct, decoupled architectural layers.

```
       [ Public Edge ]          --> Internet Gateway & Route 53
              │
    ┌─────────┴─────────┐
    │  Web Tier (PaaS)  │       --> Public ALB + Private Apache EC2 Auto Scaling
    └─────────┬─────────┘
              │
    ┌─────────┴─────────┐
    │  App Tier (API)   │       --> Internal ALB + Private Node.js/PM2 EC2 Auto Scaling
    └─────────┬─────────┘
              │
    ┌─────────┴─────────┐
    │  Database Tier    │       --> Isolated RDS MySQL + Private Route 53 DNS
    └───────────────────┘
```

---

## 2. Project Scope

### In-Scope (Implemented & Declared)
1. **Network Foundation:**
   - Dedicated AWS Virtual Private Cloud (VPC) with CIDR `10.30.0.0/16`.
   - Multi-AZ segmentation spanning `us-east-1a` and `us-east-1b`.
   - Two public subnets for edge routing and administrative jump access.
   - Six private subnets segmented into Web, Application, and Database tiers.
   - Regional NAT Gateway enabling outbound internet access for private instances without exposing inbound routes.
2. **Application Delivery & Routing:**
   - Public-facing Application Load Balancer (ALB) terminating HTTPS/TLS.
   - Backend Application Load Balancer routing internal API traffic.
   - Amazon Route 53 public hosted zone record mapping (`somu.rebel7781.xyz`, `api.rebel7781.xyz`).
   - Automated SSL/TLS certificate issuance and DNS validation using AWS Certificate Manager (ACM).
3. **Compute & Auto Scaling:**
   - EC2 Launch Templates for Frontend (Apache HTTP) and Backend (Node.js/PM2).
   - Auto Scaling Groups (ASGs) distributing workloads across availability zones.
   - Public Bastion Host (jump box) for secure operational administration.
4. **Data Persistence:**
   - Amazon RDS MySQL instance deployed into a private database subnet group.
   - Route 53 Private Hosted Zone (`rds.com`) providing internal DNS resolution (`book.rds.com`).

### Explicit Scope Boundaries & Non-Assumptions
- **Application Source Code:** The repository provisions cloud infrastructure. Application codebases (`/home/ubuntu/aws_three_tier_code/backend`) are assumed to be baked into pre-existing golden AMIs or deployed via configuration management (Ansible/CodeDeploy).
- **Continuous Deployment (CD) Runner:** GitHub Actions workflows define the enterprise CI/CD pattern; production execution requires configuring AWS OIDC roles in your specific AWS account.

---

## 3. Architecture Assumptions vs. Verified Implementation

To maintain engineering integrity, the table below contrasts declared Terraform definitions against runtime assumptions:

| Component | Intended Architecture Design | Verified Implementation in Current Code | Engineering Remediation / Roadmap |
| :--- | :--- | :--- | :--- |
| **Network Security** | Least-privilege security groups per tier | Single shared Security Group permitting `0.0.0.0/0` across all ports | Split into 4 security groups (ALB, Web, App, DB) |
| **Backend ALB Exposure** | Internal ALB placed in private subnets | ALB declared with `internal = false` in public subnets | Change `internal = true` and attach to private app subnets |
| **HTTP-to-HTTPS** | Automatic redirect from port 80 to 443 | Port 80 listeners forward directly to target groups | Update ALB listener default action to redirect 80 -> 443 |
| **Auto Scaling Capacity** | Dynamic multi-instance scaling (`min=2, max=6`) | Hardcoded to `min_size = 1`, `max_size = 1`, `desired = 1` | Scale parameters for multi-instance high availability |
| **RDS Availability** | Multi-AZ standby replica for zero downtime | `multi_az` is not declared (defaults to Single-AZ) | Enable `multi_az = true` in RDS configuration |
| **Secrets Management** | AWS Secrets Manager / Parameter Store | Plain-text database password declared in Terraform & script | Integrate `aws_secretsmanager_secret` & dynamic injection |
| **Instance Connectivity** | Private instances with no public IPs | Launch templates enforce `associate_public_ip_address = false` | Verified: Private instances route outbound via NAT |

---

## 4. Key Design Decisions

### Modular Terraform Structure
The architecture is decomposed into reusable, isolated modules under `module/`:
- `vpc`: Owns network topology, subnets, IGW, NAT Gateway, and route table associations.
- `loadbalancer`: Provisions ALBs, target groups, and HTTP/HTTPS listeners.
- `lanuch_template`: Manages EC2 configuration, user-data bootstrap scripts, and network interfaces.
- `autoscaling_grouping`: Manages capacity lifecycle, scaling parameters, and target group attachments.
- `RDS`: Manages subnet groups, MySQL database engine, storage, and security groups.
- `route53`: Orchestrates public A Alias records and private hosted zone CNAME mappings.
- `acm`: Automates SSL/TLS certificate generation and Route 53 DNS validation records.
- `bastion_host`: Delivers a perimeter bastion host for SSH tunneling into private instances.

### Regional NAT Gateway vs. Dual NAT Gateways
- To optimize baseline infrastructure operating costs while supporting outbound patching, a single regional NAT Gateway is utilized in public subnet 1.
- For strict enterprise fault tolerance across AZ outages, independent NAT Gateways per AZ can be enabled.

---

## 5. Technology Stack Summary

- **Cloud Provider:** Amazon Web Services (AWS)
- **Infrastructure as Code:** HashiCorp Terraform (`>= 1.5.0`)
- **AWS Provider Version:** `hashicorp/aws` (`~> 5.0` or `~> 6.0`)
- **DNS & Security:** Amazon Route 53, AWS Certificate Manager (ACM)
- **Compute:** Amazon EC2, Auto Scaling Groups, Launch Templates
- **Operating System:** Ubuntu Server 22.04 LTS
- **Web/App Stack:** Apache HTTP Server, Node.js, PM2 process manager
- **Database:** Amazon RDS MySQL (Engine 8.0 compatible, gp3 storage)
- **CI/CD & Tooling:** GitHub Actions, TFLint, Checkov
