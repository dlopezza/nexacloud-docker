
variable "db_name" {
  type        = string
  default     = "nexadb"
}

variable "db_username" {
  type        = string
  sensitive   = true
  default     = "nexatest"
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
