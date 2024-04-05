output "webserver_sg_id" {
  value = aws_security_group.webserver.id
}

output "loadbalancer_sg_id" {
  value = aws_security_group.load_balancer.id
}
