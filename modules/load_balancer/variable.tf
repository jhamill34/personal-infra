variable "name" {
  type        = string
  description = "The name of the load balancer"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnets to attach the load balancer to"
}

variable "security_group_id" {
  type        = string
  description = "The security group to attach the load balancer to"
}

