variable vpc_name {
  type        = string
  description = "name of the vpc"
}

variable public_subnet_cidr_block {
  type        = string
  default     = "10.0.1.0/24"
  description = "description"
}

variable private_subnet1_cidr_block {
  type        = string
  default     = "10.0.2.0/24"
  description = "description"
}

variable private_subnet2_cidr_block {
  type        = string
  default     = "10.0.3.0/24"
  description = "description"
}


variable main_az {
  type        = string
  default     = "us-east-1a"
  description = "description"
}

variable replication_az {
  type        = string
  default     = "us-east-1b"
  description = "description"
}

