# Troubleshooting & Debugging Guide

---

## 1. Overview

This troubleshooting runbook documents root cause analyses (RCA), diagnostic procedures, and resolutions for real-world issues encountered when developing, deploying, and operating this AWS Three-Tier Terraform project.

---

## 2. Common Issues & Solutions Matrix

### Issue 1: Terraform Dependency Cycle Error
- **Symptom:**
  ```text
  Error: Cycle: module.route53.aws_route53_record.alb_backend,
  module.load_balancer.aws_lb_listener.backend_https_listener,
  module.acm.aws_acm_certificate_validation.cert_validation
  ```
- **Root Cause:**
  When `module.acm` references an output from `module.route53` (e.g. `zone_id`), while `module.route53` references outputs from `module.load_balancer` (e.g. ALB DNS/Zone ID), and `module.load_balancer` references the certificate ARN from `module.acm`, Terraform forms a circular dependency graph:
  $$\text{ACM} \longrightarrow \text{Load Balancer} \longrightarrow \text{Route 53} \longrightarrow \text{ACM}$$
- **Resolution:**
  Decouple the modules so `module.acm` resolves the hosted zone independently using `data "aws_route53_zone" "zone" { name = var.domain_name }`. This converts the cycle into a strict Directed Acyclic Graph (DAG):
  $$\text{ACM} \longrightarrow \text{Load Balancer} \longrightarrow \text{Route 53}$$

---

### Issue 2: AWS ELB Name Constraints (`InvalidParameterValue`)
- **Symptom:**
  ```text
  Error: creating ELBv2 Application Load Balancer (frontend_lb):
  InvalidParameterValue: Load balancer name 'frontend_lb' may only contain
  alphanumeric characters and hyphens.
  ```
- **Root Cause:**
  AWS Application Load Balancer and Target Group names forbid underscores (`_`).
- **Resolution:**
  Replace underscores with hyphens in resource names:
  `frontend-lb`, `backend-lb`, `frontend-tg`, `backend-tg`.

---

### Issue 3: ACM Certificate Stuck in `PENDING_VALIDATION`
- **Symptom:**
  Terraform hangs or fails when attaching a certificate to an ALB listener:
  ```text
  Error: creating ELBv2 Listener: UnsupportedCertificate: The certificate
  'arn:aws:acm:...' is not in 'ISSUED' state.
  ```
- **Diagnostic Commands:**
  ```bash
  # Check certificate details and domain validation records
  aws acm describe-certificate \
    --certificate-arn <CERT_ARN> \
    --query "Certificate.DomainValidationOptions"
  ```
- **Root Cause:**
  The DNS validation CNAME records required by ACM were either not created in Route 53 or were created in the wrong hosted zone.
- **Resolution:**
  Ensure `module.acm` creates `aws_route53_record.cert_validation` in the matching hosted zone and awaits `aws_acm_certificate_validation.cert_validation` before passing the ARN to ALB listeners.

---

### Issue 4: ALB Returns `502 Bad Gateway` / Unhealthy Targets
- **Symptom:**
  Navigating to `https://somu.rebel7781.xyz` yields an HTTP 502 error, and the AWS Management Console shows target health as `unhealthy`.
- **Diagnostic Procedure:**
  1. Jump through the bastion host to inspect the private instance:
     ```bash
     ssh -A ubuntu@<BASTION_IP>
     ssh ubuntu@<PRIVATE_INSTANCE_IP>
     ```
  2. Inspect cloud-init bootstrap logs:
     ```bash
     cat /var/log/cloud-init-output.log
     ```
  3. Verify service status and local port listening:
     ```bash
     sudo systemctl status apache2
     sudo netstat -tlpn | grep :80
     ```
- **Root Cause:**
  - The web server (`apache2`) failed to install during cloud-init (e.g. transient package manager lock or network timeout via NAT Gateway).
  - Target group health check path (`/`) did not return an HTTP 200 response.
  - Target group port was set to 80 while backend application was listening on port 5000.
- **Resolution:**
  Ensure user-data scripts include error checking and wait for network readiness. Align target group health check port with application listening port.

---

### Issue 5: Backend Application Cannot Connect to MySQL Database
- **Symptom:**
  ```text
  ERROR 2005 (HY000): Unknown MySQL server host 'book.rds.com' (110)
  # or
  ERROR 2003 (HY000): Can't connect to MySQL server on 'book.rds.com' (110)
  ```
- **Diagnostic Procedure:**
  1. Verify private DNS resolution from backend EC2:
     ```bash
     nslookup book.rds.com
     ```
     If NXDOMAIN: verify the Route 53 private hosted zone association (`aws_route53_zone.rds_private.vpc.vpc_id`) matches the VPC ID of the EC2 instances.
  2. Test network connectivity on TCP port 3306:
     ```bash
     nc -zv book.rds.com 3306 -w 5
     ```
  3. Check RDS Subnet Group and Security Group:
     Confirm RDS security group ingress allows inbound port 3306 from the Backend EC2 security group.
- **Resolution:**
  Ensure the Route 53 private zone is properly associated with the VPC, and verify that `rds_endpoint` passed to the CNAME record is the database address (`module.database.db_address`) rather than the full endpoint with port (`:3306`).

---

### Issue 6: Bastion Host SSH `Permission Denied (publickey)`
- **Symptom:**
  ```text
  Permission denied (publickey).
  ```
- **Root Cause:**
  - Incorrect SSH key specified (`-i path/to/key.pem`).
  - Incorrect username for the OS (e.g., using `ec2-user` on an Ubuntu AMI instead of `ubuntu`).
  - Key file permissions too permissive (`chmod 400 ~/.ssh/ansible.pem`).
- **Resolution:**
  ```bash
  chmod 400 ~/.ssh/ansible.pem
  ssh -i ~/.ssh/ansible.pem ubuntu@<BASTION_PUBLIC_IP>
  ```
