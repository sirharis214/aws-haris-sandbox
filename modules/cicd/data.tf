locals {
  name = "aws-haris-sandbox-cicd" # repo name where ci/cd will originate from
}

data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

