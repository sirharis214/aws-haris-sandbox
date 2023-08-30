resource "aws_s3_bucket" "this" {
  bucket_prefix = local.module_name
  tags          = local.tags
}

/*
resource "aws_s3_bucket_acl" "this" {
  # This bucket has the bucket owner enforced setting applied for Object Ownership 
  # When bucket owner enforced is applied, use bucket policies to control access
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}
*/

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
