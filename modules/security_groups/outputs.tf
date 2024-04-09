output "webserver_sg_id" {
  value       = aws_security_group.webserver.id
  description = "ID of the webserver security group"
}

output "loadbalancer_sg_id" {
  value       = aws_security_group.load_balancer.id
  description = "ID of the load balancer security group"
}
