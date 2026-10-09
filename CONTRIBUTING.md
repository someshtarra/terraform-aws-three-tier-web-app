# Contributing Guidelines

Thank you for contributing to the **AWS Three-Tier Web Application Infrastructure** project! This repository follows enterprise DevOps best practices, standard git workflows, and strict Infrastructure as Code (IaC) linting and security policies.

---

## 1. Code of Conduct & Principles
- **No Hardcoded Secrets:** Never commit access keys, secret tokens, private SSH keys, or plain-text database credentials.
- **Reproducibility:** All resources must be provisioned and destroyed cleanly using Terraform without manual console interventions.
- **Least Privilege:** Security group rules, IAM policies, and subnet routes must adhere to the principle of least privilege.

---

## 2. Development Workflow

1. **Fork or Branch:**
   Create a descriptive feature branch from `main`:
   ```bash
   git checkout -b feat/internal-backend-alb
   # or
   git checkout -b fix/asg-capacity-scaling
   ```

2. **Format and Validate Locally:**
   Before opening a pull request, run the local quality checks:
   ```bash
   # Canonical formatting
   terraform fmt -recursive

   # Syntax and configuration validation
   terraform validate

   # Static code analysis
   tflint --init && tflint
   ```

3. **Check Security Compliance:**
   If Checkov or tfsec is installed locally, run:
   ```bash
   checkov -d . --framework terraform
   ```

4. **Verify Speculative Plan:**
   Run a local speculative plan against your sandbox environment:
   ```bash
   terraform plan -var-file="terraform.tfvars"
   ```

5. **Commit and Push:**
   Follow conventional commits:
   - `feat(network): add multi-az nat gateway routing`
   - `fix(asg): increase maximum capacity to 3 instances`
   - `docs(readme): update request flow architecture diagram`

---

## 3. Terraform Code Standards

### Naming Conventions
- Resources must use lowercase alphanumeric characters and hyphens or underscores matching cloud provider constraints (e.g., AWS Application Load Balancers forbid underscores; use hyphens `frontend-lb`).
- Tags must be applied to all taggable resources:
  ```hcl
  tags = {
    Project     = "AWS-Three-Tier-App"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
  ```

### Module Design
- Every module in `module/` must have:
  - `main.tf` (Resource declarations)
  - `variables.tf` (Explicitly typed variable definitions with descriptions)
  - `output.tf` (Explicitly documented outputs)

---

## 4. Pull Request Review Process
- All PRs trigger the automated GitHub Actions CI pipeline (`.github/workflows/terraform.yml`).
- A minimum of one peer review approval is required before merging.
- Direct pushes to `main` are restricted.
