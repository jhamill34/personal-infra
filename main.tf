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

module "test-cluster" {
  source     = "./projects/container_cluster"
  name       = "test-cluster"
  cidr_block = "10.0.0.0/16"
}

