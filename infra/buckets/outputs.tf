output "docker_bucket" {
  description = "The name of the Docker S3 bucket"
  value       = aws_s3_bucket.dockerBucket.bucket
}

output "images_bucket" {
  description = "The name of the Docker S3 bucket"
  value       = aws_s3_bucket.imagesBucket.bucket
}

output "dockerrun_key" {
  description = "The name of the Docker S3 bucket"
  value       = aws_s3_object.dockerrun.key
}