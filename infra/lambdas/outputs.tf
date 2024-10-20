output "api_gateway_url" {
  value       = "https://${aws_api_gateway_rest_api.LambdasApi.id}.execute-api.us-east-1.amazonaws.com/default/${var.path}"
  description = "API Gateway URL for the Lambda function"
}