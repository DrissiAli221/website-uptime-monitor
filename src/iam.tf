resource "aws_iam_role" "lambda_executor_role" {
  name = "WebsiteUptimeCheckerRole"

  # Policy allows the Lambda service to assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy: Defines what the Lambda function is allowed to do
resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "AWSLambdaBasicLoggingPolicy"
  description = "Allows Lambda logs to CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvent"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attachment" {
  role       = aws_iam_role.lambda_executor_role.id
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

