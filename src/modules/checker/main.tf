data "archive_file" "checker_new" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/checker.zip"
}

resource "aws_lambda_function" "multi_region_checker" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_executor.arn
  filename         = data.archive_file.checker_new.output_path
  source_code_hash = data.archive_file.checker_new.output_base64sha256
  handler          = "checker.handler"
  runtime          = "python3.9"
  timeout          = 15

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
      DB_REGION      = var.primary_region
    }
  }
}




resource "aws_iam_role" "lambda_executor" {
  name = "${var.function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Policies (Logging + DynamoDB)
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.function_name}-policy"
  role = aws_iam_role.lambda_executor.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow",
        Action   = ["dynamodb:PutItem"],
        Resource = var.dynamodb_table_arn
      }
    ]
  })

}
