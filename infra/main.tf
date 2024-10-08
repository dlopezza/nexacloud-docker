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