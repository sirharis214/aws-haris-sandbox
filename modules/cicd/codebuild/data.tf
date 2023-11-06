locals {
  name         = "aws-haris-sandbox-cicd"
  assume_roles = values(var.assume_roles) # ARN's of the roles we need permission to assume
  codebuilds   = toset(["plan", "apply"])
}

data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

data "local_file" "plan" {
  filename = "${path.module}/docs/buildspec.plan.yml"
}

data "local_file" "apply" {
  filename = "${path.module}/docs/buildspec.apply.yml"
}
