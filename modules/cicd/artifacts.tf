/*
Artifacts created by AWS CodeBuild projects will be stored in this bucket.
The IAM role cicd-codebuild-xxx needs permissions to access this bucket, so 
when creating a instance of the codebuild module, pass the name and arn of this bucket as well. 
*/
resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "cicd-artifacts-"
  tags          = local.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
