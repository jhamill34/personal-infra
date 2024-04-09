output "listener_arn" {
  value       = aws_lb_listener.alb.arn
  description = "The ARN of the listener"
}
