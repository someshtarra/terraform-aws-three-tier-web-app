# Cost Estimation & FinOps Optimization Guide

---

## 1. Executive Cost Summary

Infrastructure cost is a key consideration when designing cloud architectures. This document provides a defensible cost model for the AWS Three-Tier Architecture in the `us-east-1` (N. Virginia) region.

> [!NOTE]
> Estimates are calculated based on standard AWS On-Demand list prices (as of 2026). Actual monthly bills vary based on network data egress, ALB Load Balancer Capacity Units (LCUs), and dynamic Auto Scaling behavior.

---

## 2. Monthly Cost Breakdown by Resource

| Service Component | Configuration & SKU | Quantity | Estimated Unit Cost | Estimated Monthly Cost |
| :--- | :--- | :--- | :--- | :--- |
| **Regional NAT Gateway** | AWS NAT Gateway (Base hourly rate) | 1 | \$0.045 / hour | **\$32.40** |
| **NAT Data Processing** | Outbound data processing | ~50 GB | \$0.045 / GB | **\$2.25** |
| **Application Load Balancers** | Frontend ALB + Backend ALB | 2 | \$0.0225 / hour per ALB | **\$32.40** |
| **ALB Capacity Units (LCU)** | Evaluated on traffic, connections, bandwidth | 2 ALBs | ~\$0.008 / LCU-hour | **\$5.80** |
| **Frontend Web Tier EC2** | `t3.medium` (2 vCPU, 4 GiB RAM, 20 GB gp3) | 1 | \$0.0416 / hr + \$1.60 storage | **\$31.55** |
| **Backend App Tier EC2** | `t3.medium` (2 vCPU, 4 GiB RAM, 20 GB gp3) | 1 | \$0.0416 / hr + \$1.60 storage | **\$31.55** |
| **Perimeter Bastion Host** | `t3.micro` (2 vCPU, 1 GiB RAM, 8 GB gp3) | 1 | \$0.0104 / hr + \$0.64 storage | **\$8.13** |
| **Amazon RDS MySQL** | `db.t3.micro` Single-AZ + 30 GB gp3 storage | 1 | \$0.017 / hr + \$3.45 storage | **\$15.69** |
| **Amazon Route 53** | 1 Public Hosted Zone + 1 Private Hosted Zone | 2 | \$0.50 / hosted zone | **\$1.00** |
| **AWS Certificate Manager** | Public Wildcard SSL/TLS Certificate | 1 | **FREE** | **\$0.00** |
| **Total Estimated Baseline Cost** | | | | **~\$160.77 / month** |

---

## 3. Major Cost Drivers Analysis

1. **NAT Gateway & Data Processing (~22% of total cost):**
   The AWS NAT Gateway charges a mandatory hourly flat rate (\$0.045/hr) regardless of traffic volume. Even with zero traffic, a running NAT Gateway incurs ~\$32.40 monthly.
2. **Dual Application Load Balancers (~24% of total cost):**
   Running two distinct ALBs (frontend and backend) incurs two base hourly charges totaling ~\$32.40/month before LCU utilization.
3. **Compute Tiers (~45% of total cost):**
   Two `t3.medium` instances represent the largest compute share. The baseline configuration runs 1 instance per tier.

---

## 4. FinOps & Cost Optimization Recommendations

### Recommendation 1: Consolidate to a Single Application Load Balancer
Instead of maintaining two distinct ALBs, configure path-based or host-based routing on a single ALB:
- Route `somu.rebel7781.xyz/*` -> Frontend Target Group (Apache)
- Route `api.rebel7781.xyz/*` -> Backend Target Group (Node.js)
- **Monthly Savings:** **~\$16.20/month** (eliminates the second ALB base charge).

### Recommendation 2: Replace Bastion EC2 with AWS Systems Manager (SSM)
Eliminate the dedicated `t3.micro` bastion host entirely by routing administration through AWS Systems Manager Session Manager.
- **Monthly Savings:** **~\$8.13/month**.

### Recommendation 3: Utilize VPC Endpoints for High-Volume AWS Services
If private EC2 instances frequently download packages from Amazon S3 (e.g. build artifacts, logs), provision a free Gateway VPC Endpoint for S3. This bypasses NAT Gateway data processing charges (\$0.045/GB).

### Recommendation 4: Development Environment Auto-Shutdown
For non-production or demo environments, configure scheduled Lambda functions or AWS EventBridge rules to scale ASGs to 0 and pause RDS instances outside business hours (e.g., 7:00 PM to 7:00 AM and weekends).
- **Potential Monthly Savings:** **~60% reduction (~$95/month saved)**.
