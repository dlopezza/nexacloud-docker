variable vpc_name {
  type        = string
  default     = "vpc_terraproject"
  description = "name of the vpc"
}

variable vpc_cidr_block {
  type        = string
  default     = "10.0.0.0/16"
  description = "description"
}

variable public_subnet_cidr_block {
  type        = string
}

variable private_subnet1_cidr_block {
  type        = string
}

variable private_subnet2_cidr_block {
  type        = string
}


variable main_az {
  type        = string
}

variable replication_az {
  type        = string
}

