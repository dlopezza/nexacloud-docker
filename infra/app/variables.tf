variable "vpc_id" {
  type        = string
  description = "Id of the VPC"
}

variable "port" {
  description = "Port used by the beanstalk host to receive traffic"
  type        = number
  default     = 80
}

variable "service_role" {
  type        = string
  description = "Id of the VPC"
  default     = "arn:aws:iam::892672557072:role/LabRole"
}

variable "docker_bucket" {
  type        = string
  description = "Name of the bucket that the dockerfile is in"
}

variable "dockerrun_key" {
  type        = string
  description = "Key of the dockerrun file"
}

variable "env_vars" {
  description = "Environment variables for the application"
  type        = map(string)
}

variable "public_subnet_id"{
    description = "Id of the public subet used for the app"
    type = string
}

variable "private_subnet_id"{
    description = "Id of the private subet used for the app"
    type = string
}

variable "instance_profile"{
    description = "Instance profile to be used by the app"
    type = string
    default = "LabInstanceProfile"
}

variable "environment"{
  type        = string
}