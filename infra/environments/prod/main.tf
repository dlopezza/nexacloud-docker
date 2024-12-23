terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = "true"
      ManagedBy  = "terraform"
    }
  }
}

module "vpc" {
  source = "../../vpc"
  environment                = var.environment
  vpc_name                   = "vpc_terraproject"  
  vpc_cidr_block             = "10.0.0.0/16"
  public_subnet_cidr_block   = "10.0.1.0/24"
  private_subnet1_cidr_block = "10.0.2.0/24"
  private_subnet2_cidr_block = "10.0.3.0/24"
  main_az                    = "us-east-1a"
  replication_az             = "us-east-1b"
}

module "db"{
    source           = "../../db"
    environment      = var.environment
    subnet_ids       = module.vpc.private_subnets
    vpc_id           = module.vpc.vpc_id
    port             = var.db_port
    db_identifier    = var.db_name
    db_name          = var.db_name
    instance_class   = "db.t3.micro"
    db_username      = var.db_username
    db_password      = var.db_password
    sg_cidr_blocks   = ["0.0.0.0/0"]
}

module "buckets"{
  source             =  "../../buckets"
  environment        = var.environment
  docker_bucket_name = "dockerbucket"
  images_bucket_name = "imagesbucket"
}

locals {
  env_vars = {
    COMPANY_NAME              = "nexa in docker"
    AWS_S3_LAMBDA_URL         = module.imagesLambda.api_gateway_url
    AWS_S3_LAMBDA_APIKEY      = module.imagesLambda.api_key
    AWS_DB_LAMBDA_URL         = module.add_row_to_db_lambda.api_gateway_url
    AWS_DB_LAMBDA_APIKEY      = module.add_row_to_db_lambda.api_key
    DB_USER                   = var.db_username
    DB_PASSWORD               = var.db_password
    DB_HOST                   = module.db.db_endpoint
    DB_DATABASE               = var.db_name
    DB_PORT                   = var.db_port
    STRESS_PATH               ="/usr/bin/stress"
    LOAD_BALANCER_IFRAME_URL  ="https://google.com"
  }
}

module "app"{
  source            = "../../app"
  environment       = var.environment
  env_vars          = local.env_vars
  vpc_id            = module.vpc.vpc_id
  port              = 80
  service_role      = "arn:aws:iam::892672557072:role/LabRole"
  docker_bucket     = module.buckets.docker_bucket
  dockerrun_key     = module.buckets.dockerrun_key
  public_subnet_id  = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet1_id
  instance_profile  = "LabInstanceProfile"
}

module "imagesLambda"{
  source          = "../../lambdas"
  environment     = var.environment
  function_name   = "imagesLambda"
  filename        = "./resources/s3Listing.zip"
  role            = "arn:aws:iam::892672557072:role/LabRole"
  handler         = "s3Listing.handler"
  runtime         = "nodejs16.x"
  path            = "images"
  httpMethod      = "GET"
  environment_variables = {
    AWS_S3_BUCKET = module.buckets.images_bucket
  }
}

module "add_row_to_db_lambda" {
  source          = "../../lambdas"
  environment     = var.environment
  filename        = "./resources/lambdaDatabaseJS.zip"
  function_name   = "add-row-to-db"
  role            = "arn:aws:iam::892672557072:role/LabRole"
  handler         = "index.lambdaHandler"
  runtime         = "nodejs16.x"
  path            = "db"
  httpMethod      = "POST"
  environment_variables = {
    DB_USER        = var.db_username
    DB_PASSWORD    = var.db_password
    DB_HOST        = module.db.db_endpoint
    DB_NAME        = var.db_name
    DB_PORT        = var.db_port
  }
    vpc_config = {
    subnet_ids         = module.vpc.private_subnets
    security_group_ids = [module.db.sg_id]
  }
}