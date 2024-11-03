output "subnet_ids" {
  description = "List of subnet IDs"
  value       = aws_subnet.this[*].id
}