data "aws_caller_identity" "current" {}

module "donothing-role" {
  source     = "../../modules/iam_role"
  name       = "${var.name}-DoNothingRole"
  account_id = data.aws_caller_identity.current.account_id
}

module "bucket" {
  source      = "../../modules/s3_bucket"
  bucket_name = "${var.name}-bucket"
  account_id  = data.aws_caller_identity.current.account_id
}

module "read-only-access-point" {
  source    = "../../modules/s3_access_point"
  name      = "read-only-access-point"
  bucket_id = module.bucket.bucket_id
  role_arn  = module.donothing-role.role_arn
  actions   = ["s3:GetObject", "s3:ListBucket"]
  prefix    = var.ap_prefix
}

module "writer-access-point" {
  source    = "../../modules/s3_access_point"
  name      = "writer-access-point"
  bucket_id = module.bucket.bucket_id
  role_arn  = module.donothing-role.role_arn
  actions   = ["s3:PutObject"]
  prefix    = var.ap_prefix
}

