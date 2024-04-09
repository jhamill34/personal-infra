variable "name" {
  type        = string
  description = "Name of the S3 access point"
}

variable "bucket_id" {
  type        = string
  description = "ID of the S3 bucket to create the access point for"
}

variable "role_arn" {
  type        = string
  description = "ARN of the role to attach the policy to"
}

variable "actions" {
  type        = list(string)
  description = "List of actions to allow the role to perform"
}

variable "prefix" {
  type        = string
  description = "Bucket Prefix to allow the role to access"
}

