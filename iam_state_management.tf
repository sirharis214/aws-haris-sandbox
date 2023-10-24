data "aws_caller_identity" "current" {
}

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
        data.aws_caller_identity.current.account_id,
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

  #   statement {
  #     sid = "AllowStateKeyAccess"

  #     actions = [
  #       "kms:Decrypt",
  #       "kms:Encrypt",
  #       "kms:DescribeKey",
  #       "kms:GenerateDataKey*",
  #     ]

  #     resources = [
  #       aws_kms_key.tf_state_key.arn,
  #     ]
  #   }

  #   statement {
  #     sid = "AllowStateLockManagement"

  #     actions = [
  #       "dynamodb:GetItem",
  #       "dynamodb:PutItem",
  #       "dynamodb:DeleteItem",
  #     ]

  #     resources = [
  #       aws_dynamodb_table.tf_state_lock.arn,
  #     ]
  #   }
}

# attach customer managed policy to iam_role
resource "aws_iam_role_policy_attachment" "state_management_policy_attachment" {
  role       = aws_iam_role.state_management_role.id
  policy_arn = aws_iam_policy.state_management_policy.arn
}
