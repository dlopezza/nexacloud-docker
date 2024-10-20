resource "aws_api_gateway_rest_api" "LambdasApi" {
  name        = "LambdasApi"
  description = "API Gateway for lambdas"
}