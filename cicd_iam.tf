# create the role that codebuild will assume
resource "aws_iam_role" "cicd" {
  name_prefix        = "cicd-codebuild-"
  assume_role_policy = data.aws_iam_policy_document.cicd_assume_policy.json

  tags = local.tags
}

# allow codebuild to assume the role
data "aws_iam_policy_document" "cicd_assume_policy" {
  statement {
    sid = "CodeBuildAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com",
      ]
    }
  }
}

# create the customer managed policy
resource "aws_iam_policy" "cicd" {
  name_prefix = "BasicExecution-"
  policy      = data.aws_iam_policy_document.cicd_permissions.json
}

# define the permissions for the customer managed policy
data "aws_iam_policy_document" "cicd_permissions" {
  statement {
    sid = "CodeBuild"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid = "S3Access"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploads",
      "s3:ListBucketMultipartUploads",
    ]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
  }

  statement {
    sid = "SSMTokenAccess"
    actions = [
      "ssm:GetParameter*",
    ]
    resources = [
      "arn:aws:ssm:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:parameter/CodeBuild.GitHub*",
    ]
  }

  statement {
    sid = "Ec2Management"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "DenyDisconnectFromSourceProviders"
    effect = "Deny"
    actions = [
      "codebuild:DeleteOAuthToken",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid = "EniManagement"
    actions = [
      "ec2:CreateNetworkInterfacePermission",
    ]
    resources = [
      "arn:aws:ec2:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:network-interface/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values = [
        "codebuild.amazonaws.com",
      ]
    }
  }
}

# attach the customer managed policy to the role
resource "aws_iam_role_policy_attachment" "cicd" {
  role       = aws_iam_role.cicd.id
  policy_arn = aws_iam_policy.cicd.arn
}

# also attach the StateManagement policy to this role
resource "aws_iam_role_policy_attachment" "state_management" {
  role       = aws_iam_role.cicd.name
  policy_arn = aws_iam_policy.state_management_policy.arn
}
