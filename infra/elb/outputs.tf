output "load_balancer_url" {
  description = "The public URL of the load balancer"
  value       = aws_lb.this.dns_name
}