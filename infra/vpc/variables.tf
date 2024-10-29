variable "vpc_name" {
  type        = string
  default     = "vpc_terraproject"
  description = "Name of the VPC"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_block" {
  type        = string
  description = "CIDR block for the public subnet"
}

variable "private_subnet1_cidr_block" {
  type        = string
  description = "CIDR block for the first private subnet"
}

variable "private_subnet2_cidr_block" {
  type        = string
  description = "CIDR block for the second private subnet"
}

variable "main_az" {
  type        = string
  description = "Availability zone for the main subnet"
}

variable "replication_az" {
  type        = string
  description = "Availability zone for the replication subnet"
}

variable "environment"{
  type        = string
}