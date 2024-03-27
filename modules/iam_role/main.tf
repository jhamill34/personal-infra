variable "name" {
  type = string
}

variable "account_id" {
  type = string
}

resource "aws_iam_role" "role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.account_id]
    }
  }
}

output "role_arn" {
  value = aws_iam_role.role.arn
}
