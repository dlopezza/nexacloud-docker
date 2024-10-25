variable "docker_bucket_name" {
  type        = string
  default     = "dockerbucket"
  description = "name for the bucket used for saving the dockerrun file"
}

variable "images_bucket_name" {
  type        = string
  default     = "imagesbucket"
  description = "name for the bucket used for saving the dockerrun file"
}
