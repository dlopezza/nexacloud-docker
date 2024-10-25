output vpc_id {
  value       = aws_vpc.vpc.id
  description = "description"
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = module.subnets.public_subnet_id
}

output "private_subnet1_id" {
  description = "The ID of the first private subnet"
  value       = module.subnets.private_subnet1_id
}

output "private_subnet2_id" {
  description = "The ID of the second private subnet"
  value       = module.subnets.private_subnet2_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.subnets.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.subnets.private_subnets
}
