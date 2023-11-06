module "cicd" {
  source = "./modules/cicd"

  kms_key_arn                 = aws_kms_key.this.arn
  state_management_policy_arn = aws_iam_policy.state_management_policy.arn

  project_tags = local.tags
}

/****   IAM Role: StateManagement   ****/

/* This IAM Role has permissions to manage the AWS Bucket with all the terraform states.
The permission policy document will be attached to cicd-codebuild role allowing 
us to read and write to/from the statefiles via CodeBuild. */

# create role
resource "aws_iam_role" "state_management_role" {
  name               = "StateManagement"
  path               = "/Terraform/"
  assume_role_policy = data.aws_iam_policy_document.state_management_assume_role_policy.json
  tags               = local.tags
}

# allow anyone from the current account to assume this role
data "aws_iam_policy_document" "state_management_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.this.account_id,
      ]
    }
  }
}

# create customer managed policy
resource "aws_iam_policy" "state_management_policy" {
  name   = "StateManagement"
  policy = data.aws_iam_policy_document.state_management_policy.json
}

# define permissions of the customer managed policy
data "aws_iam_policy_document" "state_management_policy" {
  statement {
    sid = "AllowStateBucketAccess"

    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

# attach customer managed policy to iam_role
resource "aws_iam_role_policy_attachment" "state_management_policy_attachment" {
  role       = aws_iam_role.state_management_role.id
  policy_arn = aws_iam_policy.state_management_policy.arn
}
