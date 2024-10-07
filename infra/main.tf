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

# Private Subnet
resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.vpc_terraproject.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

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

resource "aws_route_table_association" "private_subnet2_route" {
  subnet_id      = aws_subnet.private_subnet2.id
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

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name        = "my-db-subnet-group"
  subnet_ids  = [aws_subnet.private_subnet.id,aws_subnet.private_subnet2.id]  # Use private subnets
  description = "RDS Subnet Group for single-instance database"
}


resource "aws_db_instance" "db" {
  identifier             = "nexadb"
  db_name                = "nexadb"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "16.3"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  username               = "nexatest"
  password               = "nexapass"
  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name
  port                   = 9876
}

resource "aws_s3_bucket" "dockerBucket" {
  bucket = "nexacloudenvironmentsaver"
}

resource "aws_s3_object" "my_dockerrun" {
  bucket = aws_s3_bucket.dockerBucket.bucket
  key    = "Dockerrun.aws.json"
  source = "Dockerrun.aws.json"

  etag = filemd5("Dockerrun.aws.json")
}

resource "aws_s3_bucket" "imagesBucket" {
  bucket = "nexacloudimagesforlambda"
}

locals {
  # List all image files in the local 'images' directory
  images = [
    for file in fileset("${path.module}/images", "*.jpg") : {
      name = file
      path = "${path.module}/images/${file}"
    }
  ]
}

resource "aws_s3_object" "image" {
  for_each = { for img in local.images : img.name => img }

  bucket = aws_s3_bucket.imagesBucket.bucket
  key    = "images/${each.value.name}" 
  source = each.value.path
  acl    = "private"  # Set the desired ACL
}

resource "aws_elastic_beanstalk_application" "my_app" {
  name        = "my-app"
  description = "My Elastic Beanstalk Application"

  appversion_lifecycle {
    service_role          = "arn:aws:iam::892672557072:role/LabRole"
    max_count             = 5
    delete_source_from_s3 = true
  }
}

resource "aws_elastic_beanstalk_application_version" "my_app_version" {
  name        = "my-app-version-${timestamp()}"
  application = aws_elastic_beanstalk_application.my_app.name
  bucket      = aws_s3_bucket.dockerBucket.bucket
  key         = aws_s3_object.my_dockerrun.key
}

locals {
  env_vars = {
    COMPANY_NAME   = "nexa in docker"
    AWS_S3_LAMBDA_URL="https://${aws_api_gateway_rest_api.LambdasApi.id}.execute-api.us-east-1.amazonaws.com/default/images"
    AWS_DB_LAMBDA_URL="https://${aws_api_gateway_rest_api.LambdasApi.id}.execute-api.us-east-1.amazonaws.com/default/db"
    STRESS_PATH="/usr/bin/stress"
    LOAD_BALANCER_IFRAME_URL="https://google.com"
  }
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
    value     = "vockey"
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

  dynamic "setting" {
    for_each = local.env_vars
    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = setting.key
      value     = setting.value
    }
  }
}

resource "aws_lambda_function" "getImages" {
  filename      = "s3Listing.zip"
  function_name = "getnexa-images-from-s3"
  role          = "arn:aws:iam::892672557072:role/LabRole"
  handler       = "s3Listing.handler"
  runtime       = "nodejs16.x"
  environment {
    variables = {
      AWS_S3_BUCKET = aws_s3_bucket.imagesBucket.bucket
    }
  }
}

resource "aws_lambda_function" "addRowToDb" {
  filename      = "lambdaDatabaseJS.zip"
  function_name = "add-row-to-db"
  role          = "arn:aws:iam::892672557072:role/LabRole"
  handler       = "index.lambdaHandler"
  runtime       = "nodejs20.x"
    environment {
    variables = {
    DB_USER        = aws_db_instance.db.username
    DB_PASSWORD    = aws_db_instance.db.password
    DB_HOST        = aws_db_instance.db.endpoint
    DB_DATABASE    = aws_db_instance.db.db_name
    DB_PORT        = aws_db_instance.db.port
    }
  }
}

resource "aws_api_gateway_rest_api" "LambdasApi" {
  name        = "LambdasApi"
  description = "API Gateway for lambdas"
}

resource "aws_api_gateway_resource" "imagesResource" {
  rest_api_id = aws_api_gateway_rest_api.LambdasApi.id
  parent_id   = aws_api_gateway_rest_api.LambdasApi.root_resource_id
  path_part   = "images"
}

resource "aws_api_gateway_resource" "dbResource" {
  rest_api_id = aws_api_gateway_rest_api.LambdasApi.id
  parent_id   = aws_api_gateway_rest_api.LambdasApi.root_resource_id
  path_part   = "db"
}

resource "aws_api_gateway_method" "getImagesMethod" {
  rest_api_id   = aws_api_gateway_rest_api.LambdasApi.id
  resource_id   = aws_api_gateway_resource.imagesResource.id
  http_method   = "GET"
  authorization = "NONE"  # No authorization for simplicity
}

resource "aws_api_gateway_method" "postDbMethod" {
  rest_api_id   = aws_api_gateway_rest_api.LambdasApi.id
  resource_id   = aws_api_gateway_resource.dbResource.id
  http_method   = "POST"
  authorization = "NONE"  # No authorization for simplicity
}

resource "aws_api_gateway_integration" "getImagesIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.LambdasApi.id
  resource_id             = aws_api_gateway_resource.imagesResource.id
  http_method             = aws_api_gateway_method.getImagesMethod.http_method
  integration_http_method = "POST"  # POST for Lambda
  type                    = "AWS_PROXY"  # AWS_PROXY integration

  uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.getImages.arn}/invocations"
}

resource "aws_api_gateway_integration" "postDbIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.LambdasApi.id
  resource_id             = aws_api_gateway_resource.dbResource.id
  http_method             = aws_api_gateway_method.postDbMethod.http_method
  integration_http_method = "POST"  # POST for Lambda
  type                    = "AWS_PROXY"  # AWS_PROXY integration

  uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.addRowToDb.arn}/invocations"
}

resource "aws_lambda_permission" "allow_apigatewayImages" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getImages.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.LambdasApi.execution_arn}/*/*"  # Allow all methods and resources
}

resource "aws_lambda_permission" "allow_apigatewayDb" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.addRowToDb.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.LambdasApi.execution_arn}/*/*"  # Allow all methods and resources
}

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.LambdasApi.id
  stage_name  = "default"  # Single deployment stage

  # Trigger redeployment for both integrations
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_integration.getImagesIntegration.id, aws_api_gateway_integration.postDbIntegration.id]))
  }
}

# Outputs the API endpoint
output "api_gateway_url_images" {
  value       = "https://${aws_api_gateway_rest_api.LambdasApi.id}.execute-api.us-east-1.amazonaws.com/default/images"
  description = "API Gateway URL"
}

output "api_gateway_url_db" {
  value       = "https://${aws_api_gateway_rest_api.LambdasApi.id}.execute-api.us-east-1.amazonaws.com/default/db"
  description = "API Gateway URL"
}


