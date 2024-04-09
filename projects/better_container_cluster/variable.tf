variable "name" {
  type        = string
  description = "A unique name for this cluster configuration"
}

variable "cidr_block" {
  type        = string
  description = "The group of IP addresses we're going to use for the VPC"
}

