/****   Main S3 Bucket   ****/

/* This Bucket will primarly hold a key terraform/ where all module statefiles will be stored.
Statefile key: terraform/<MODULE_NAME>/terraform.tfstate
Example, the current module (this repo) is aws-haris-sandbox, so the backend config will look like this:

backend "s3" {
  region = "us-east-1"
  bucket = "aws-haris-sandbox20230828153749772900000001"
  key    = "terraform/aws-haris-sandbox/terraform.tfstate"
} */

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
