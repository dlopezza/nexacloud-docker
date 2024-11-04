terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  registry_auth {
    address  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

resource "aws_ecr_repository" "repository" {
  name = "myapp"
}

resource "docker_registry_image" "backend" {
  name = "${aws_ecr_repository.repository.repository_url}:latest"

  build {
    context    = "../app"
    dockerfile = "dockerfile"
  }
}

output "repository_url" {
  value = aws_ecr_repository.repository.repository_url
}
