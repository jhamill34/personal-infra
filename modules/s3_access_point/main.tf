variable "name" {
  type = string
}

variable "bucket_id" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "actions" {
  type = list(string)
}

variable "prefix" {
  type = string
}

resource "aws_s3_access_point" "access_point" {
  name   = var.name
  bucket = var.bucket_id

  public_access_block_configuration {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

resource "aws_s3control_access_point_policy" "access_point_policy" {
  access_point_arn = aws_s3_access_point.access_point.arn
  policy           = data.aws_iam_policy_document.access_point_policy.json
}

data "aws_iam_policy_document" "access_point_policy" {
  statement {
    actions = var.actions
    effect  = "Allow"
    resources = [
      aws_s3_access_point.access_point.arn,
      "${aws_s3_access_point.access_point.arn}/object/${var.prefix}/*",
    ]
    principals {
      type        = "AWS"
      identifiers = [var.role_arn]
    }
  }
}
