variable environment {
  type        = string
}

variable public_subnets_ids {
  type        = list(string)
  description = "List of subnets to use for the load balancer"
}

variable private_subnets_ids{
  type        = list(string)
  description = "List of subnets to use for the load balancer"
}

variable vpc_id {
  type        = string
  description = "Id of the vpc to use in the lb target group"
}


