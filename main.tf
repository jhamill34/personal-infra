terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "docker" {}

provider "aws" {
  region  = "us-west-2"
  profile = "personal"
}

data "aws_caller_identity" "current" {}

module "donothing-role" {
  source     = "./modules/iam_role"
  name       = "Terraform-DoNothingRole"
  account_id = data.aws_caller_identity.current.account_id
}

module "test-bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "jhamill-terraform-bucket"
  account_id  = data.aws_caller_identity.current.account_id
}

module "read-only-access-point" {
  source    = "./modules/s3_access_point"
  name      = "read-only-access-point"
  bucket_id = module.test-bucket.bucket_id
  role_arn  = module.donothing-role.role_arn
  actions   = ["s3:GetObject", "s3:ListBucket"]
  prefix    = "datadog"
}

module "writer-access-point" {
  source    = "./modules/s3_access_point"
  name      = "writer-access-point"
  bucket_id = module.test-bucket.bucket_id
  role_arn  = module.donothing-role.role_arn
  actions   = ["s3:PutObject"]
  prefix    = "datadog"
}

module "test-cluster" {
  source = "./modules/cluster"
  name   = "terraform-cluster"
}

module "jhamill-service-web" {
  source = "./modules/container_repo"
  name   = "jhamill-service-web"
}

module "jhamill-service-vpc" {
  source = "./modules/vpc"
  name   = "jhamill-service-vpc"
}

module "jhamill-service-subnet-az-1" {
  source                = "./modules/subnets"
  name                  = "jhamill-service-subnet-az-1"
  availability_zone     = "us-west-2a"
  vpc_id                = module.jhamill-service-vpc.vpc_id
  public_cidr_block     = "10.0.1.0/24"
  private_cidr_block    = "10.0.2.0/24"
  public_route_table_id = module.jhamill-service-vpc.public_route_table_id
}

module "jhamill-service-subnet-az-2" {
  source                = "./modules/subnets"
  name                  = "jhamill-service-subnet-az-1"
  availability_zone     = "us-west-2b"
  vpc_id                = module.jhamill-service-vpc.vpc_id
  public_cidr_block     = "10.0.3.0/24"
  private_cidr_block    = "10.0.4.0/24"
  public_route_table_id = module.jhamill-service-vpc.public_route_table_id
}

