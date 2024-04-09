output "role_arn" {
  value       = aws_iam_role.role.arn
  description = "The ARN of the IAM role that allows the account to assume the role"
}
