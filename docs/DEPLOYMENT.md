# Deployment & Operations Guide

---

## 1. Prerequisites & Environment Setup

Before provisioning the AWS Three-Tier Infrastructure, ensure your local workstation or CI/CD runner satisfies the following prerequisites:

### Software Requirements
- **Terraform:** Version `1.5.0` or higher (`terraform -version`)
- **AWS CLI:** Version `2.10.0` or higher (`aws --version`)
- **Git:** Version `2.30.0` or higher
- **TFLint (Optional, recommended):** `v0.50.0`+
- **OpenSSH Client:** For bastion host tunneling

### AWS Account Requirements
1. **IAM Permissions:** Sufficient administrative access to provision:
   - VPC, Subnets, Route Tables, Internet Gateways, NAT Gateways
   - EC2 Instances, Launch Templates, Auto Scaling Groups
   - Elastic Load Balancing (Application Load Balancers, Target Groups)
   - Amazon RDS (DB Subnet Groups, DB Instances)
   - Amazon Route 53 (Hosted Zones and Records)
   - AWS Certificate Manager (ACM Certificates)
2. **Route 53 Public Hosted Zone:** An existing registered domain configured as a public hosted zone (e.g., `rebel7781.xyz`).
3. **EC2 Key Pair:** An existing EC2 Key Pair created in your target region (e.g., named `ansible`).

---

## 2. Configuration & Parameter Setup

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/your-username/aws-three-tier-terraform.git
   cd aws-three-tier-terraform
   ```

2. **Prepare Environment Variables:**
   Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Customize `terraform.tfvars`:**
   Update domain names, AMI IDs, and DB credentials to match your environment:
   ```hcl
   aws_region   = "us-east-1"
   domain_name  = "yourdomain.com"
   key_name     = "your-keypair-name"
   ```

   > [!IMPORTANT]
   > Ensure that the AMI IDs specified in your variables exist in your target region (`us-east-1`). If using fresh Ubuntu 22.04 LTS AMIs, verify that user-data scripts or application packages are properly configured.

---

## 3. Step-by-Step Deployment Workflow

![Deployment Workflow](../assets/deployment_workflow.png)

### Step 1: Initialize Terraform
Initialize the provider plugins and module tree:
```bash
terraform init
```

### Step 2: Validate Syntax and Format
Ensure code formatting and declarative structure comply with standards:
```bash
terraform fmt -check
terraform validate
```

### Step 3: Run Static Analysis (Optional)
```bash
tflint --init
tflint
```

### Step 4: Generate a Speculative Plan
Inspect all resources that Terraform proposes to create:
```bash
terraform plan -out=tfplan
```
Review the proposed changes:
- Anticipated additions: ~28 resources (VPC, Subnets, Gateways, ALBs, ASGs, RDS, Route 53, ACM).
- Anticipated changes/destructions: 0.

### Step 5: Execute Deployment
Apply the generated execution plan:
```bash
terraform apply tfplan
```
*Note: Full deployment typically takes 5 to 9 minutes, primarily driven by Amazon RDS MySQL instance creation and ACM DNS certificate validation.*

---

## 4. Post-Deployment Verification Checklist

Once `terraform apply` finishes successfully, retrieve the generated outputs:
```bash
terraform output
```

### Verification Steps

1. **Verify ACM SSL Certificate Validation:**
   ```bash
   aws acm list-certificates --region us-east-1
   # Confirm Certificate Status is "ISSUED" (not PENDING_VALIDATION)
   ```

2. **Verify Route 53 DNS Propagation:**
   ```bash
   dig +short somu.rebel7781.xyz
   dig +short api.rebel7781.xyz
   # Confirm output resolves to public ALB IP addresses
   ```

3. **Verify HTTPS Frontend Endpoint:**
   ```bash
   curl -Iv https://somu.rebel7781.xyz
   # Confirm HTTP/2 200 or valid SSL handshake
   ```

4. **Verify Application Load Balancer Target Health:**
   ```bash
   # Check Frontend Target Group Health
   aws elbv2 describe-target-health \
     --target-group-arn $(terraform output -raw frontend_tg_arn) \
     --region us-east-1
   ```

5. **Test Administrative Bastion Access:**
   SSH into the bastion host, then jump to a private web or app tier instance:
   ```bash
   # Add your key to SSH agent
   ssh-add ~/.ssh/ansible.pem

   # SSH to Bastion with Agent Forwarding
   ssh -A ubuntu@<BASTION_PUBLIC_IP>

   # From the Bastion shell, SSH to private instance IP
   ssh ubuntu@<PRIVATE_WEB_INSTANCE_IP>
   ```

6. **Verify Database Connectivity from Private App Tier:**
   From an instance in the private application tier, verify private DNS resolution and MySQL port availability:
   ```bash
   nslookup book.rds.com
   nc -zv book.rds.com 3306
   ```

---

## 5. Teardown & Destruction Guide

To prevent recurring AWS charges after evaluation or testing, destroy all provisioned infrastructure:

```bash
# 1. Inspect destruction plan
terraform plan -destroy

# 2. Execute resource destruction
terraform destroy -auto-approve
```

> [!CAUTION]
> `terraform destroy` will terminate all EC2 instances and drop the RDS MySQL database. Because `skip_final_snapshot = true` is configured in testing mode, no final automated snapshot will be preserved.
