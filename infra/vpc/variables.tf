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
variable "subnet_count"{
  type        = number
  description = "ammount of subnets to create for each type"
  default     = 2
}