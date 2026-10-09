# TFLint Configuration File
# https://github.com/terraform-linters/tflint

config {
  module = true
  force = false
  disabled_by_default = false
}

# AWS Ruleset
plugin "aws" {
  enabled = true
  version = "0.36.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Enforce standard formatting and deprecations
rule "terraform_deprecated_syntax" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}
