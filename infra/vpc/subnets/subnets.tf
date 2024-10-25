resource "aws_subnet" "public_subnet" {
  vpc_id                = var.vpc_id
  cidr_block            = var.public_subnet_cidr_block
  availability_zone     = var.main_az

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
}

resource "aws_route_table_association" "public_subnet_route" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
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

# NAT Gateway for Private Subnets
resource "aws_eip" "nat_eip" {
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id    = aws_subnet.public_subnet.id 

  tags = {
    Name = "nat-gateway"
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0" 
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate Route Table with Private Subnet
resource "aws_route_table_association" "private_subnet_route" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet2_route" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}
