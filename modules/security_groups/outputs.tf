output "loadbalancer_sg_id" {
  value = aws_security_group.loadbalancer.id
}

output "webserver_sg_id" {
  value = aws_security_group.webserver.id
}

output "database_sg_id" {
  value = aws_security_group.database.id
}
