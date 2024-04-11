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
  region  = "us-east-1"
  profile = "personal"
}

// NOTE: Don't remove this since its used to register domain names that 
// we've purchased. Changes to existing domains will change their name servers
// requiring us to update them in the domain registrar.
module "root_dns" {
  source = "./projects/root_dns"
}

module "blog_jhamill_tech_project" {
  source         = "./projects/blog_jhamill_tech"
  parent_zone_id = module.root_dns.jhamill_tech.zone_id
}
