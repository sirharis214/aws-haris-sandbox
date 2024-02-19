## required permission to run terraform plan

```hcl
# The SSO Instance
data "aws_ssoadmin_instances" "sso" {}

# SSO's PowerUserAccess permission set
data "aws_ssoadmin_permission_set" "power_user_access" {
  instance_arn = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  name         = "PowerUserAccess"
}

# custom IAM policy
resource "aws_iam_policy" "power_user_access" {
  name        = "PowerUserAccess"
  policy      = data.aws_iam_policy_document.power_user_access.json
  description = "Additional permissions required to run terraform plan"

  tags = local.tags
}

# custom IAM policy's permissions
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

# attaching custom IAM policy to SSO's PowerUserAccess permission set 
resource "aws_ssoadmin_customer_managed_policy_attachment" "power_user_access" {
  instance_arn       = data.aws_ssoadmin_permission_set.power_user_access.instance_arn
  permission_set_arn = data.aws_ssoadmin_permission_set.power_user_access.arn
  customer_managed_policy_reference {
    name = aws_iam_policy.power_user_access.name
  }
}

```
