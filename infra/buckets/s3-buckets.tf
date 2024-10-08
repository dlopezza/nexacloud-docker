resource "random_string" "bucket_suffix" {
  length  = 8
  upper   = false
  lower   = true
  numeric  = true
  special = false
}

resource "aws_s3_bucket" "dockerBucket" {
  bucket = "${var.docker_bucket_name}-${random_string.bucket_suffix.result}"
}

resource "aws_s3_object" "my_dockerrun" {
  bucket = aws_s3_bucket.dockerBucket.bucket
  key    = "Dockerrun.aws.json"
  source = "${path.cwd}/resources/Dockerrun.aws.json"

  etag = filemd5("${path.cwd}/resources/Dockerrun.aws.json")
}

resource "aws_s3_bucket" "imagesBucket" {
  bucket = "${var.images_bucket_name}-${random_string.bucket_suffix.result}"  # Corrected string interpolation
}

locals {
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
  acl    = "private"
}
