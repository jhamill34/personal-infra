variable "name" {
  type        = string
  description = "The name of the service"
}

variable "cluster_id" {
  type        = string
  description = "The cluster id"
}

variable "vpc_id" {
  type        = string
  description = "The vpc id"
}

variable "listener_arn" {
  type        = string
  description = "The listener arn"
}

variable "health_check_path" {
  type        = string
  description = "The health check path"
}

variable "instances" {
  type        = number
  description = "The number of instances"
}

