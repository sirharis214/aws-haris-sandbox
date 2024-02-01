/****   Main S3 Bucket   ****/

/* This Bucket will primarly hold a key terraform/ where all module statefiles will be stored.
Statefile key: terraform/<MODULE_NAME>/terraform.tfstate
Example, the current module (this repo) is aws-haris-sandbox, so the backend config will look like this:

backend "s3" {
  region = "us-east-1"
  bucket = "aws-haris-sandbox20230828153749772900000001"
  key    = "terraform/aws-haris-sandbox/terraform.tfstate"
} 

See bottom of the page for the bucket policy I manually attached 
to allow all users in the AWS Account to be able to store terraform state files in the bucket
*/

resource "aws_s3_bucket" "this" {
  bucket_prefix = local.module_name
  tags          = local.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

/*
This Policy should have been attached to bucket via terraform but i did it manually.

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessFromSpecificAccount",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::594924424566:root"
            },
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObjectTagging"
            ],
            "Resource": "arn:aws:s3:::aws-haris-sandbox20230828153749772900000001/*"
        }
    ]
}

A similar policy to allow not everyone but only specific IAM Roles would be:

resource "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"]
    }

    resources = [
      "arn:aws:s3:::YOUR_BUCKET_NAME/terraform/*",
    ]
  }
}
*/
