resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block 
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

module "subnets" {
  source = "./subnets"

  vpc_id                   = aws_vpc.vpc.id
  vpc_name                 = var.vpc_name
  public_subnet_cidr_block = var.public_subnet_cidr_block
  private_subnet1_cidr_block = var.private_subnet1_cidr_block
  private_subnet2_cidr_block = var.private_subnet2_cidr_block
  main_az                 = var.main_az
  replication_az          = var.replication_az
}

