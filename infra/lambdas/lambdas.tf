resource "aws_lambda_function" "this" {
  filename      = var.filename
  function_name = var.function_name
  role          = var.role
  handler       = var.handler
  runtime       = var.runtime

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [1] : []
    content {
      subnet_ids         = var.vpc_config.subnet_ids
      security_group_ids = var.vpc_config.security_group_ids
    }
  }
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.LambdasApi.id
  parent_id   = aws_api_gateway_rest_api.LambdasApi.root_resource_id
  path_part   = var.path
}

resource "aws_api_gateway_method" "this" {
  rest_api_id   = aws_api_gateway_rest_api.LambdasApi.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = var.httpMethod
  authorization = "NONE"  # No authorization for simplicity
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = aws_api_gateway_rest_api.LambdasApi.id
  resource_id             = aws_api_gateway_resource.this.id
  http_method             = aws_api_gateway_method.this.http_method
  integration_http_method = "POST"  # POST for Lambda
  type                    = "AWS_PROXY"  # AWS_PROXY integration

  uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.this.arn}/invocations"
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway-${var.function_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.LambdasApi.execution_arn}/*/*"  # Allow all methods and resources
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.LambdasApi.id
  stage_name  = "default"  # Single deployment stage
  
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_integration.this]))
  }
}
