data "aws_caller_identity" "current" {}
data "aws_ecr_authorization_token" "token" {}


resource "aws_ecr_repository" "this" {
  name = "repository-${var.environment}"
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