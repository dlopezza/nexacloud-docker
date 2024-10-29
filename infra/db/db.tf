resource "aws_security_group" "db_sg" {
  name        = "db_sg-${var.environment}"
  description = "Security group for the db"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.sg_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group-${var.environment}"
  subnet_ids = var.subnet_ids
  description = "RDS Subnet Group for single-instance database"

  tags = {
    Name = "sb_subnet_group"
  }
}

resource "aws_db_instance" "db" {
  identifier             = "var.db_identifier-${var.environment}"
  db_name                = "${var.db_name}-${var.environment}"
  instance_class         = var.instance_class
  allocated_storage       = 5
  engine                 = "postgres"
  engine_version         = "16.3"
  skip_final_snapshot     = true
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  port                   = var.port
}
