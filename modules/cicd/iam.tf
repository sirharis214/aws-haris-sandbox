/*
This IAM role is assumed when setting the provider config to be used in cicd CodeBuild project.
It has all the permissions to create infra in the AWS Account.

When ci/cd pulls the github repo and attempts to do a terraform plan or apply, 
it will utilize this IAM Role instead of CodeBuilds service role which has limited permissions.
*/

# The external_id that must match when assuming this role
# stored in AWS Secrets Manager manually
data "aws_secretsmanager_secret" "external_id" {
  name = "CodeBuild.AwsHarisSandbox.TerraformManagement"
}
data "aws_secretsmanager_secret_version" "external_id" {
  secret_id = data.aws_secretsmanager_secret.external_id.id
}

# create the role
resource "aws_iam_role" "terraform_management" {
  name               = "${local.name}-terraform-management"
  assume_role_policy = data.aws_iam_policy_document.terraform_management_assume.json

  tags = local.tags
}

# allow only codebuild's service role to assume this role
data "aws_iam_policy_document" "terraform_management_assume" {
  statement {
    sid     = "AllowCICDAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        module.codebuild.cicd_codebuild_role_arn,
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        "${jsondecode(data.aws_secretsmanager_secret_version.external_id.secret_string)["external_id"]}"
      ]
    }
  }
}

# attach the AWS Managed Admin policy to this role
data "aws_iam_policy" "AdministratorAccess" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
resource "aws_iam_role_policy_attachment" "AdministratorAccess" {
  role       = aws_iam_role.terraform_management.name
  policy_arn = data.aws_iam_policy.AdministratorAccess.arn
}
