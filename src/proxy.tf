data "archive_file" "proxy_file" {
  type        = "zip"
  source_dir  = "${path.module}/proxy"
  output_path = "${path.module}/dist/proxy.zip"
}

resource "aws_lambda_function" "proxy" {
  function_name    = "CrossRegionProxy"
  role             = aws_iam_role.proxy_role.arn
  handler          = "proxy.handler"
  runtime          = "python3.9"
  filename         = data.archive_file.proxy_file.output_path
  source_code_hash = data.archive_file.proxy_file.output_base64sha256
  timeout          = 30

}






resource "aws_iam_role" "proxy_role" {
  name = "CrossRegionProxyRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Allow Proxy to call the Europe Lambda
resource "aws_iam_role_policy" "proxy_invoke_policy" {
  name = "AllowInvokeEurope"
  role = aws_iam_role.proxy_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = module.eu_check.lambda_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogsEvents"
        ],
        Resource = "*"
      }
    ]
  })
}
