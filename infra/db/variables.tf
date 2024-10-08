variable "subnet_ids" {
  type        = string
  description = "Id of the subnets used in the db"
}

variable "vpc_id" {
  type        = string
  description = "Id of the VPC"
}

variable "port" {
  description = "Database port"
  type        = number
  default     = 9876
}

variable "sg_cidr_blocks" {
  description = "List of CIDR blocks for the security group ingress rules"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "db_identifier" {
  description = "Database identifier"
  type        = string
  default     = "nexadb"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "nexadb"
}

variable "instance_class" {
  description = "Instance class for the database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
  default     = "nexatest"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "nexapass"
}


