/*
This resource provides the IAM Identity Center's 'AdministratorAccess' Permission Set 
access to the AWS Secret Manager secret that we manually created for ci/cd.

See README.md for information and purpose of the secret.

The id name of the resource is codebuild_provider_assume_role because 
the secret's values are used when configuring the role that the provider assumes in CI/CD provider config.
*/
resource "aws_iam_policy" "codebuild_provider_assume_role" {
  name        = "CodebuildProviderAssumeRole"
  policy      = data.aws_iam_policy_document.codebuild_provider_assume_role.json
  description = "Permission to access the secret stored in Secrets Manager with values that belongs to the IAM role assumed in provider config in CodeBuild projects."

  tags = local.tags
}

data "aws_iam_policy_document" "codebuild_provider_assume_role" {
  statement {
    sid    = "ExternalIdAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:us-east-1:594924424566:secret:CodeBuild.AwsHarisSandbox.TerraformManagement-TcTxxq"
    ]
  }
}

# attach policy to AdministratorAccess permission set
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment
resource "aws_ssoadmin_customer_managed_policy_attachment" "codebuild_provider_assume_role" {
  instance_arn       = data.aws_ssoadmin_permission_set.admin_access.instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.admin_access.arn
  customer_managed_policy_reference {
    name = aws_iam_policy.codebuild_provider_assume_role.name
  }
}
