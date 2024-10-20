
variable "db_name" {
  type        = string
  default     = "nexatest"
}

variable "db_username" {
  type        = string
  sensitive   = true
  default     = "nexadb"
}

variable "db_password" {
  type        = string
  sensitive   = true
  default     = "nexapass"
}

variable "db_port"{
  type        = number
  default     = 9876
}
