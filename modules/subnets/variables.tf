variable "name" {
  type        = string
  description = "The name of the subnet"
}

variable "availability_zone" {
  type        = string
  description = "The availability zone for the subnet"
}

variable "public_cidr_block" {
  type        = string
  description = "The CIDR block for the public subnet"
}

variable "private_cidr_block" {
  type        = string
  description = "The CIDR block for the private subnet"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "public_route_table_id" {
  type        = string
  description = "The ID of the route table for the public subnet"
}

