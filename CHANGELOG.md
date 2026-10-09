# Changelog

All notable changes to the AWS Three-Tier Architecture Terraform codebase will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-10-09

### Added
- **Complete Modular AWS VPC Architecture:**
  - Regional NAT Gateway configuration with private subnet routing.
  - Dual public subnets across `us-east-1a` and `us-east-1b`.
  - Six private subnets segmented into dedicated Web, App, and Database tiers.
- **Dual Application Load Balancers:**
  - Public Frontend Application Load Balancer with port 80 HTTP and port 443 HTTPS listeners.
  - Backend Application Load Balancer with port 80 and port 443 listeners.
- **Automated Route 53 & ACM Integration:**
  - Automated DNS validation using Route 53 CNAME verification records.
  - Route 53 Alias `A` records mapped dynamically to ALB DNS names and Hosted Zone IDs.
  - Route 53 Private Hosted Zone (`rds.com`) providing internal DNS resolution (`book.rds.com`) for the database endpoint.
- **Compute & Auto Scaling:**
  - Launch Templates for Frontend (Apache HTTP) and Backend (Node.js/PM2).
  - Explicit configuration disabling public IPs on private EC2 instances (`associate_public_ip_address = false`).
  - Auto Scaling Groups wired directly to target group ARNs.
- **Data Persistence:**
  - Amazon RDS MySQL instance configured in private DB subnet group.
  - `publicly_accessible = false` and `skip_final_snapshot = true`.
- **Administrative Perimeter:**
  - Bastion Host jump server deployed in public subnet for secure SSH tunneling.
- **DevOps Tooling & CI/CD:**
  - GitHub Actions automated CI/CD pipeline for formatting, validation, TFLint, Checkov security scanning, and automated planning.
  - Pull Request and Issue templates.
  - Production-ready documentation suite and architectural diagrams.

### Identified Technical Debt & Roadmap
- Segment monolithic Security Group into 4 distinct tier-specific least-privilege groups.
- Migrate backend ALB to `internal = true` within private application subnets.
- Configure HTTP-to-HTTPS redirect action on port 80 listeners.
- Externalize plain-text RDS credentials to AWS Secrets Manager.
- Enable Multi-AZ RDS deployment for enterprise high availability.
- Scale Auto Scaling Groups to `min_size = 2`, `max_size = 4` across AZs.
