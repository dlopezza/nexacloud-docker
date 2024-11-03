variable "vpc_name"{
  type        = string
  description = "Name of the VPC"
}

variable "vpc_id" {
  type        = string
  description = "Id of the VPC"
}

variable "cidr_block" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for the subnet"
}

variable "az" {
  type        = string
  default     = "us-east-1a"
  description = "main availability zone for the subnets"
}

variable "replication_az" {
  type        = string
  default     = "us-east-1b"
  description = "Replication availability zone for the subnets"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, prod)"
}

variable "route_table" {
  type        = string
  description = "Route table for the subnet"
}

variable "is_public_subnet" {
  type        = bool
  description = "Boolean used to define public and private subnet properties"
}

variable "number" {
  type        = number
  description = "Number used in the subnet name for differentiation"
}
