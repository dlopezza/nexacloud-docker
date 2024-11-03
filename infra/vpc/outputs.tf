output vpc_id {
  value       = aws_vpc.this.id
  description = "description"
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = [for subnet in module.public_subnets : subnet.subnet_id]
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = [for subnet in module.private_subnets : subnet.subnet_id]
}
