terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./vpc"

  vpc_name                = "vpc_terraproject"  
  vpc_cidr_block          = "10.0.0.0/16"
  public_subnet_cidr_block = "10.0.1.0/24"
  private_subnet1_cidr_block = "10.0.2.0/24"
  private_subnet2_cidr_block = "10.0.3.0/24"
  main_az                = "us-east-1a"
  replication_az         = "us-east-1b"
}

module "db"{
    source     = "./db"
    subnet_ids = module.vpc.private_subnets
    vpc_id     = module.vpc.vpc_id
    port       = 9876
    db_identifier    = "nexadb"
    db_name          = "nexadb"
    instance_class   = "db.t3.micro"
    db_username      = "nexatest"
    db_password      = "nexapass"
    sg_cidr_blocks   = ["0.0.0.0/0"]
}

module "docker"{
  source      =  "./buckets"
  docker_bucket_name = "dockerbucket"
  images_bucket_name = "imagesbucket"
}
