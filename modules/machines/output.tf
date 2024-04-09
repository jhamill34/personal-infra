output "autoscaling_arn" {
  value       = aws_autoscaling_group.this.arn
  description = "ARN of the autoscaling group"
}
