output "docker_bucket_name" {
  description = "The name of the Docker S3 bucket"
  value       = aws_s3_bucket.dockerBucket.bucket
}

output "images_bucket_name" {
  description = "The name of the Docker S3 bucket"
  value       = aws_s3_bucket.imagesBucket.bucket
}