variable "name_prefix" {
  type        = string
  description = "Prefix for the name of the resources"
}

variable "security_group_id" {
  type        = string
  description = "ID of the security group to attach to the network interface"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to launch the instances in"
}

variable "instance_profile" {
  type        = string
  description = "Name of the IAM instance profile to attach to the instances"
}

variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster to attach the instances to"
}

variable "public_ip" {
  type        = bool
  default     = false
  description = "Whether to associate a public IP address with the instances"
}

variable "capacity" {
  type        = number
  description = "Number of instances to launch"
}

variable "capacity_type" {
  type        = string
  default     = "t4g.micro"
  description = "Instance type to launch"
}

