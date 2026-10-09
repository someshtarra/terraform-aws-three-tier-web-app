## Description
Briefly describe the proposed infrastructure changes and the business/architectural motivation.

## Type of Change
- [ ] Infrastructure Bug fix (non-breaking change fixing an outage or deployment issue)
- [ ] Architecture Enhancement (e.g., adding resources, refactoring modules)
- [ ] Security Hardening (security group rule tightening, IAM least privilege)
- [ ] Cost Optimization (rightsizing instance families, lifecycle rules)
- [ ] Documentation / Diagram Update

## Terraform Verification Checklist
- [ ] `terraform fmt -check` passes with no formatting issues
- [ ] `terraform validate` succeeds with 0 errors
- [ ] `tflint` reports no warnings or lint errors
- [ ] Checked against Checkov / security best practices (no open `0.0.0.0/0` ingress rules where avoidable)
- [ ] No hardcoded passwords, AWS access keys, or private keys committed
- [ ] Speculative `terraform plan` output reviewed:
  - Resources to add: `X`
  - Resources to change: `Y`
  - Resources to destroy: `Z`

## Blast Radius & Rollback Plan
- **Estimated Blast Radius:** (e.g., Target groups, DB subnet group, Route 53 records)
- **Rollback Strategy:** (e.g., revert Git commit, apply previous plan, manual intervention needed)
