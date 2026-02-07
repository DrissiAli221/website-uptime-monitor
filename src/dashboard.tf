data "archive_file" "reader_zip" {
  type        = "zip"
  source_dir  = "${path.module}/reader"
  output_path = "${path.module}/dist/reader.zip"
}


resource "aws_lambda_function" "reader" {
  function_name    = "WebsiteResultReader"
  role             = aws_iam_role.reader_role.arn
  handler          = "reader.handler"
  runtime          = "python3.9"
  filename         = data.archive_file.reader_zip.output_path
  source_code_hash = data.archive_file.reader_zip.output_base64sha256

  environment {
    variables = {
      "DYNAMODB_TABLE" = aws_dynamodb_table.uptime_results.name
    }
  }
}


# Read only
resource "aws_iam_role" "reader_role" {
  name = "WebsiteReaderRole"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow"
          Action = "sts:AssumeRole"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "reader_policy" {
  name = "WebsiteReaderPolicy"
  role = aws_iam_role.reader_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["dynamodb:Scan", "dynamodb:Query"],
        Resource = aws_dynamodb_table.uptime_results.arn
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "*"
      }
    ]
  })
}


# API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "UptimeMonitorAPI"
  protocol_type = "HTTP"
  # enable cors for browser
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["Content-Type"]
  }
}

# auto deployment 
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# connects to lambda saver
resource "aws_apigatewayv2_integration" "reader_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.reader.invoke_arn
}

resource "aws_apigatewayv2_route" "get_history" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /history"
  target    = "integrations/${aws_apigatewayv2_integration.reader_integration.id}"
}

# allow API gateway to call lambda
resource "aws_lambda_permission" "api_gw" {
  function_name = aws_lambda_function.reader.function_name
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*/history"
}

output "api_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

