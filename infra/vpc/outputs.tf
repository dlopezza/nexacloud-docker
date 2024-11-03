output vpc_id {
  value       = aws_vpc.this.id
  description = "description"
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.public_subnets.subnet_ids
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.private_subnets.subnet_ids
}
