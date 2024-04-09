output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "public_route_table_id" {
  value       = aws_route_table.public_route_table.id
  description = "The ID of the route table for the public subnet"
}
