variable "bucket_name" {
  type = string
}

variable "account_id" {
  type = string
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "bucket-bpa" {
  bucket                  = aws_s3_bucket.bucket.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-sse" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "bucket-booo" {
  bucket = aws_s3_bucket.bucket.bucket
  rule {
    // This will disable ACLs and only allow bucket policies. 
    // ACLs are a discouraged practice and should be avoided.
    // Objects in the bucket are by default owned by the bucket 
    // with this flag
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "bucket-versioning" {
  bucket = aws_s3_bucket.bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.bucket.bucket
  policy = data.aws_iam_policy_document.bucket-policy.json
}

data "aws_iam_policy_document" "bucket-policy" {
  # When not using TLS, deny all S3 actions on this bucket to everyone.
  # Copied from example here: https://aws.amazon.com/premiumsupport/knowledge-center/s3-bucket-policy-for-config-rule/
  statement {
    sid = "RequireTLS"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    effect = "Deny"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }

  statement {
    sid = "AccessPointDelegation"
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:DataAccessPointAccount"
      values   = [var.account_id]
    }
  }
}

output "bucket_id" {
  value = aws_s3_bucket.bucket.id
}

