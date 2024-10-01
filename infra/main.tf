terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_availability_zones" "available" {}

provider "aws" {
  region = "us-east-1"
}

data "aws_elastic_beanstalk_solution_stack" "docker_stack" {
  most_recent = true
  name_regex  = "64bit Amazon Linux 2023 (.*) running Docker"
}

resource "aws_vpc" "vpc_terraproject" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-terraproject"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                = aws_vpc.vpc_terraproject.id
  cidr_block            = "10.0.1.0/24"
  availability_zone     = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc_terraproject.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc_terraproject.id

  tags = {
    Name = "internet_gateway"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_terraproject.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_route" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# NAT Gateway for Private Subnet 
resource "aws_eip" "nat_eip" {
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id    = aws_subnet.public_subnet.id

  tags = {
    Name = "nat-gateway"
  }
}

# Route Table for Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_terraproject.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

# Associate Route Table with Private Subnet
resource "aws_route_table_association" "private_subnet_route" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "myapp_sg" {
  name        = "myapp_sg"
  description = "Security group for myapp"
  vpc_id      = aws_vpc.vpc_terraproject.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Security group for the"
  vpc_id      = aws_vpc.vpc_terraproject.id

  ingress {
    from_port   = 9876
    to_port     = 9876
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_instance" "db" {
  identifier             = "nexadb"
  name                   = "nexadb"
  db_name                = "nexadb"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "16.3"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  username               = "nexatest"
  password               = "nexapass"
  availability_zone      = "us-east-1"
  }

resource "aws_s3_bucket" "my_app_bucket" {
  bucket = "nexacloudenvironmentsaver"
}

resource "aws_s3_object" "my_dockerrun" {
  bucket = aws_s3_bucket.my_app_bucket.bucket
  key    = "Dockerrun.aws.json"
  source = "Dockerrun.aws.json"

  etag = filemd5("Dockerrun.aws.json")
}

resource "aws_elastic_beanstalk_application" "my_app" {
  name        = "my-app"
  description = "My Elastic Beanstalk Application"

  appversion_lifecycle {
    service_role          = "arn:aws:iam::587298106973:role/LabRole"
    max_count             = 5
    delete_source_from_s3 = true
  }
}

resource "aws_elastic_beanstalk_application_version" "my_app_version" {
  name        = "my-app-version-${timestamp()}"
  application = aws_elastic_beanstalk_application.my_app.name
  bucket      = aws_s3_bucket.my_app_bucket.bucket
  key         = aws_s3_object.my_dockerrun.key
}

resource "aws_elastic_beanstalk_environment" "my_env" {
  name                = "my-env"
  application         = aws_elastic_beanstalk_application.my_app.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.docker_stack.name
  version_label       = aws_elastic_beanstalk_application_version.my_app_version.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "LabInstanceProfile"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "NexaCloudKey"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.vpc_terraproject.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.public_subnet.id}"  # Use only the private subnet for EC2 instances
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${aws_subnet.public_subnet.id}"  # Use only the public subnet for ELB
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"  # Set to false for private instances
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.myapp_sg.id
  }
}
