variable "name" {
  type        = string
  description = "A unique name for this cluster configuration"
}

variable "autoscaling_group_arn" {
  type        = string
  description = "The ARN of the autoscaling group to use for the capacity provider"
}

