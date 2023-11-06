/*
This IAM Role will be assumed by AWS CodeBuild. 
The permissions are for creating the build environment.

There is a separate role with permissions to create infrastructure in the account.
That role is assumed while configuring the aws provider in CodeBuild environment.
*/
# create the role
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

  tags = local.tags
}

# define the permissions for the customer managed policy
data "aws_iam_policy_document" "cicd_permissions" {
  statement {
    sid = "AssumeRoles"
    actions = [
      "sts:AssumeRole",
    ]
    resources = local.assume_roles
  }

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
    sid    = "ReportGroups"
    effect = "Allow"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages",
    ]
    resources = flatten([for phase in local.codebuilds : [
      "arn:aws:codebuild:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:report-group/${local.name}-${phase}-*"
    ]])
  }

  statement {
    sid = "S3ArtifactsAccess"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListMultipartUploads",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
    ]
    resources = [
      var.artifacts_bucket.arn,
      "${var.artifacts_bucket.arn}/*",
    ]
  }
  statement {
    sid    = "CWPermissions"
    effect = "Allow"

    resources = flatten([for phase in local.codebuilds : [
      "arn:aws:logs:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:log-group:/aws/codebuild/${local.name}-${phase}",
      "arn:aws:logs:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:log-group:/aws/codebuild/${local.name}-${phase}:*",
    ]])

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
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
  policy_arn = var.state_management_policy_arn
}
