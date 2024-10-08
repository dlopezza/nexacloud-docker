resource "aws_subnet" "public_subnet" {
  vpc_id                = var.vpc_id
  cidr_block            = var.public_subnet_cidr_block
  availability_zone     = var.main_az

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id                = var.vpc_id
  cidr_block            = var.private_subnet1_cidr_block
  availability_zone     = var.main_az

  tags = {
    Name = "${var.vpc_name}-private-subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id                = var.vpc_id
  cidr_block            = var.private_subnet2_cidr_block
  availability_zone     = var.replication_az

  tags = {
    Name = "${var.vpc_name}-private-subnet2"
  }
}

