variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}

variable "vpc_id" {
  type        = string
  description = "Id of the vpc"
}

variable "public_subnet_cidr_block" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for the public subnet"
}

variable "private_subnet1_cidr_block" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR block for the first private subnet"
}

variable "private_subnet2_cidr_block" {
  type        = string
  default     = "10.0.3.0/24"
  description = "CIDR block for the second private subnet"
}

variable "main_az" {
  type        = string
  default     = "us-east-1a"
  description = "Availability zone for the main subnet"
}

variable "replication_az" {
  type        = string
  default     = "us-east-1b"
  description = "Availability zone for the replication subnet"
}
