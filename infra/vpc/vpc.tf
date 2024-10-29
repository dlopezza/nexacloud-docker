resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block 
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-${var.environment}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-igw-${var.environment}"
  }
}


module "subnets" {
  source = "./subnets"
  environment              = var.environment
  vpc_id                   = aws_vpc.vpc.id
  vpc_name                 = aws_vpc.vpc.tags["Name"]
  public_subnet_cidr_block = var.public_subnet_cidr_block
  private_subnet1_cidr_block = var.private_subnet1_cidr_block
  private_subnet2_cidr_block = var.private_subnet2_cidr_block
  main_az                 = var.main_az
  replication_az          = var.replication_az
  igw_id                  = aws_internet_gateway.igw.id
}

