variable "name" {
  type = string
}

variable "bucket_id" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "actions" {
  type = list(string)
}

variable "prefix" {
  type = string
}

