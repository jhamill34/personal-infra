variable "name_prefix" {
  type        = string
  description = "Prefix for the name of the resources"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to create the security groups in"
}

