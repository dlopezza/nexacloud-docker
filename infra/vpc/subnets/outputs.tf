output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet1_id" {
  description = "The ID of the first private subnet"
  value       = aws_subnet.private_subnet1.id
}

output "private_subnet2_id" {
  description = "The ID of the second private subnet"
  value       = aws_subnet.private_subnet2.id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public_subnet.id]
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = [
    aws_subnet.private_subnet1.id,
    aws_subnet.private_subnet2.id,
  ]
}
