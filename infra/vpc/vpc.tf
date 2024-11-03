resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block 
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-${var.environment}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw-${var.environment}"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}


# NAT Gateway for Private Subnets
resource "aws_eip" "nat_eip" {
}

resource "aws_nat_gateway" "this" {
  depends_on    = [module.public_subnets]
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = module.public_subnets.subnet_ids[0]

  tags = {
    Name = "nat-gateway-${var.environment}"
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0" 
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name           = "private-route-table-${var.environment}"
  }
}

module "public_subnets"{
  count             = var.subnet_count
  source            = "./subnet"
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  az                = var.az
  replication_az    = var.replication_az
  route_table       = aws_route_table.public_route_table.id
  is_public_subnet  = true
  number            = count.index
  environment       = var.environment
}

module "private_subnets"{
  count             = var.subnet_count
  source            = "./subnet"
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + var.subnet_count)
  az                = var.az
  replication_az    = var.replication_az
  route_table       = aws_route_table.private_route_table.id
  is_public_subnet  = false
  number            = count.index
  environment       = var.environment
}