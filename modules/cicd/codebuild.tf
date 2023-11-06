module "codebuild" {
  source = "./codebuild"

  assume_roles = {
    aws_haris_sandbox_cicd_terraform_management = "${aws_iam_role.terraform_management.arn}",
  }
  artifacts_bucket = {
    name = "${aws_s3_bucket.artifacts.id}"
    arn  = "${aws_s3_bucket.artifacts.arn}"
  }
  state_management_policy_arn = var.state_management_policy_arn
  kms_key_arn                 = var.kms_key_arn

  project_tags = local.tags
}
