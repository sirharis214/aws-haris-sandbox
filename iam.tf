/*
  As part of the manual AWS account configuration, we enabled AWS IAM Identity Center and created a few resources under it.
  Of those resources are 2 User Groups [Admin, PowerUser] for which we have 2 AWS Managed Permission Sets [PowerUserAccess, AdministratorAccess].
  We want to create a custom IAM Policy and attach it to the permission set PowerUserAccess to allow power user's the abiliity to run terraform plan.
  As power users they can't create iam resources but they should be able to read them. 
*/

resource "aws_iam_policy" "power_user_access" {
  name        = "PowerUserAccess"
  policy      = data.aws_iam_policy_document.power_user_access.json
  description = "Additional permissions required to run terraform plan"

  tags = local.tags
}

data "aws_iam_policy_document" "power_user_access" {
  statement {
    sid       = "RunTfPlan"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
    ]
  }
}
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment
resource "aws_ssoadmin_customer_managed_policy_attachment" "power_user_access" {
  instance_arn       = data.aws_ssoadmin_permission_set.power_user_access.instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.power_user_access.arn
  customer_managed_policy_reference {
    name = aws_iam_policy.power_user_access.name
  }
}
