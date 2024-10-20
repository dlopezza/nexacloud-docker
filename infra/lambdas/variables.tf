variable "filename" {
  description = "The location of the Lambda function zip file."
  type        = string
}

variable "function_name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "role" {
  description = "The ARN of the IAM role for the Lambda function."
  type        = string
}

variable "handler" {
  description = "The function entry point in the Lambda code."
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Lambda function."
  type        = string
}

variable "path" {
  description = "The path to use in the gateway."
  type        = string
}

variable "httpMethod" {
  description = "HTTP method used by the API"
  type        = string
}

# Environment variables passed as a map
variable "environment_variables" {
  description = "A map of environment variables for the Lambda function."
  type        = map(string)
  default     = {}
}

# Optional VPC configuration
variable "vpc_config" {
  description = "Optional VPC configuration (subnet_ids, security_group_ids)"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}