output "role_name" {
  value       = aws_iam_role.ecs_role.name
  description = "The name of the IAM role that allows EC2 instances to make ECS calls"
}

output "profile_name" {
  value       = aws_iam_instance_profile.ecs_role.name
  description = "The name of the IAM instance profile that allows EC2 instances to make ECS calls"
}
