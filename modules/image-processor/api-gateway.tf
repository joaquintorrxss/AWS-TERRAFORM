# ============================================================
# API GATEWAY HTTP API
# ============================================================

resource "aws_apigatewayv2_api" "http" {
  name          = "image-processor-${var.environment}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = [
      "content-type"
    ]

    allow_methods = [
      "POST",
      "OPTIONS"
    ]

    allow_origins = [
      "*"
    ]
  }

  tags = {
    Environment = var.environment
    Project     = "image-processor"
  }
}

# ============================================================
# INTEGRACION API GATEWAY -> LAMBDA
# ============================================================

resource "aws_apigatewayv2_integration" "upload" {
  api_id = aws_apigatewayv2_api.http.id

  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.upload.invoke_arn

  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
}

# ============================================================
# POST /upload
# ============================================================

resource "aws_apigatewayv2_route" "upload" {
  api_id = aws_apigatewayv2_api.http.id

  route_key = "POST /upload"

  target = "integrations/${aws_apigatewayv2_integration.upload.id}"
}

# ============================================================
# STAGE DEFAULT
# ============================================================

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.http.id

  name        = "$default"
  auto_deploy = true

  tags = {
    Environment = var.environment
    Project     = "image-processor"
  }
}

# ============================================================
# PERMISO API GATEWAY -> LAMBDA
# ============================================================

resource "aws_lambda_permission" "api_gateway_upload" {
  statement_id  = "AllowAPIGatewayUpload"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}