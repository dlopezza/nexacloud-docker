output "db_instance_id" {
  description = "The ID of the RDS database instance"
  value       = aws_db_instance.db.id
}

output "db_endpoint" {
  description = "The endpoint of the RDS database instance"
  value       = split(":", aws_db_instance.db.endpoint)[0]
}

output "sg_id" {
  description = "The endpoint of the RDS database instance"
  value       = aws_security_group.db_sg.id
}