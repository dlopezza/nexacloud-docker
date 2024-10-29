output "api_gateway_url" {
  value       = "https://${aws_api_gateway_rest_api.LambdasApi.id}.execute-api.us-east-1.amazonaws.com/${var.environment}/${var.path}"
  description = "API Gateway URL for the Lambda function"
}

output "api_key" {
  description = "The API key for accessing the API Gateway"
  value       = aws_api_gateway_api_key.api_key.value
}