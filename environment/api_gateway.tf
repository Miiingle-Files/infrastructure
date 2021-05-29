locals {
  api_methods = ["GET", "POST", "PUT", "DELETE"]
}

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.org}-${var.env}"
  description   = "API for the ${var.org} ${var.env} Platform"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins     = ["http://localhost:3000"]
    allow_credentials = true
    allow_headers     = ["*"]
    allow_methods     = ["*"]
    max_age           = 300
  }

  tags = local.common_tags
}

resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "prod"
  description = "Production API"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode(
      {
        httpMethod     = "$context.httpMethod"
        stage          = "$context.stage"
        path           = "$context.path"
        ip             = "$context.identity.sourceIp"
        protocol       = "$context.protocol"
        requestId      = "$context.requestId"
        requestTime    = "$context.requestTime"
        responseLength = "$context.responseLength"
        status         = "$context.status"
      }
    )
  }

  default_route_settings {
    data_trace_enabled       = false
    detailed_metrics_enabled = true
    throttling_burst_limit   = 1000
    throttling_rate_limit    = 1000
  }

  tags = local.common_tags
}

resource "aws_apigatewayv2_route" "main" {
  count     = length(local.api_methods)
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "${local.api_methods[count.index]} /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.main.id}"
}

resource "aws_apigatewayv2_integration" "main" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"

  description        = "${var.org}-${var.env}-platform-integration"
  integration_method = "POST"
  integration_uri    = aws_lambda_alias.platform_prod.invoke_arn
}

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/${var.org}-${var.env}/api-gateway"
  retention_in_days = 7
}

resource "aws_apigatewayv2_domain_name" "api_gateway" {
  domain_name = aws_acm_certificate.api_gateway_ssl.domain_name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_gateway_ssl.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  depends_on = [
    aws_acm_certificate_validation.api_gateway_ssl_cert_validation
  ]
}

resource "aws_apigatewayv2_api_mapping" "api_gateway" {
  domain_name = aws_apigatewayv2_domain_name.api_gateway.id
  api_id      = aws_apigatewayv2_api.main.id
  stage       = aws_apigatewayv2_stage.main.id

  depends_on = [
    aws_acm_certificate.api_gateway_ssl,
    aws_acm_certificate_validation.api_gateway_ssl_cert_validation
  ]
}