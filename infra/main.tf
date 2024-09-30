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

# Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc_terraproject.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_route" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "myapp_sg" {
  name        = "myapp_sg"
  description = "Security group for myapp"
  vpc_id      = aws_vpc.vpc_terraproject.id

  ingress {
    from_port   = 3000
    to_port     = 3000
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
  name           = "my-env"
  application    = aws_elastic_beanstalk_application.my_app.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.docker_stack.name
  version_label  = aws_elastic_beanstalk_application_version.my_app_version.name

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "CNAME"
    value     = "nexacloud-aws-docker" 
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "InstanceProfile"
    value     = "LabInstanceProfile"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "KeyPair"
    value     = "Vockey"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.vpc_terraproject.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.public_subnet.id},${aws_subnet.private_subnet.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = aws_subnet.public_subnet.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "false"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "SecurityGroups"
    value     = aws_security_group.myapp_sg.id
  }
}

