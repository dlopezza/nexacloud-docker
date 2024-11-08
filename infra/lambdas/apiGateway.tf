resource "aws_api_gateway_rest_api" "LambdasApi" {
  name        = "LambdasApi-${var.environment}"
  description = "API Gateway for lambdas"
}

resource "aws_api_gateway_api_key" "api_key" {
  name = "nexa-api-key-${var.environment}"
}

resource "aws_api_gateway_stage" "default" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.LambdasApi.id
  stage_name    = var.environment
  depends_on    = [aws_api_gateway_deployment.this]
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name = "nexa-usage-plan-${var.environment}"
  depends_on = [aws_api_gateway_deployment.this, aws_api_gateway_stage.default]

  api_stages {
    api_id = aws_api_gateway_rest_api.LambdasApi.id
    stage  = aws_api_gateway_stage.default.stage_name
  }

  quota_settings {
    limit  = 1000
    period = "MONTH"
  }

  throttle_settings {
    burst_limit = 100
    rate_limit  = 50
  }

  lifecycle {
  create_before_destroy = true
  }
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
  depends_on    = [aws_api_gateway_stage.default, aws_api_gateway_usage_plan.usage_plan]
}
