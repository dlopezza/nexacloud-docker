provider "docker" {
  registry_auth {
    address  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}
data "aws_caller_identity" "current" {}
data "aws_ecr_authorization_token" "token" {}


resource "aws_ecr_repository" "this" {
  name = "repository-${var.environment}}"
}

resource "docker_image" "this" {
  name = "${aws_ecr_repository.repository.repository_url}:latest" 
  build {
    context    = "../../application"
    dockerfile = "dockerfile"
  }
}

resource "docker_registry_image" "this" {
  name          = docker_image.this.name
  keep_remotely = false
}