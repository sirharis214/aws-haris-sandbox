/****   Main KMS Key   ****/

/* The default KMS key we use in our AWS Account

We also use this key to encrypt our cicd AWS CodeBuild projects. 
By using a customer managed key we can grant 2 sperate CodeBuild projects access to the same key.
This way shared artifacts between the 2 projects can be encrypted and decrypted. */

resource "aws_kms_key" "this" {
  description  = "Main multi-region KMS key"
  multi_region = true
  policy       = data.aws_iam_policy_document.key_perms.json

  tags = merge(local.tags, { is_multi_region = "true" })
}

resource "aws_kms_alias" "this" {
  name          = "alias/main-kms-key"
  target_key_id = aws_kms_key.this.key_id
}

data "aws_iam_policy_document" "key_perms" {
  statement {
    sid    = "TerraformManagement"
    effect = "Allow"
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        data.aws_caller_identity.this.arn,
      ]
    }
  }

  # This statement would allow aws users to be granted select read
  # conditions that allow them to list keys in the key management system
  # and prevent them from obtaining errors
  statement {
    sid    = "ReadOnly"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:List*",
      "kms:GetKey*",
    ]
    resources = [
      "*",
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
      ]
    }
  }
}

# granting KMS key access to the IAM Role that CodeBuild will assume
resource "aws_kms_grant" "this" {
  key_id            = aws_kms_key.this.key_id
  grantee_principal = module.cicd.cicd_codebuild_role_arn
  operations = [
    "Decrypt",
    "ReEncryptFrom",
    "ReEncryptTo",
    "Encrypt",
    "GenerateDataKey",
    "GenerateDataKeyWithoutPlaintext",
    "DescribeKey",
  ]
}
