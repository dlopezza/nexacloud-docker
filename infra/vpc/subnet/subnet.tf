resource "aws_subnet" "this" {
  vpc_id                = var.vpc_id
  cidr_block            = var.cidr_block
  availability_zone     = var.number % 2 != 0 ? var.az : var.replication_az

  map_public_ip_on_launch = var.is_public_subnet? true: false

  tags = {
    Name = "${var.vpc_name}-${var.is_public_subnet ? "public-subnet" : "private-subnet"}-${var.number}-${var.environment}"
  }
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = var.route_table
}