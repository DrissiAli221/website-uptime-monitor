data "archive_file" "saver_zip" {
  type        = "zip"
  source_dir  = "${path.module}/saver"
  output_path = "${path.module}/dist/saver.zip"
}

resource "aws_lambda_function" "saver" {
  function_name    = "WebsiteResultSaver"
  role             = aws_iam_role.saver_role.arn
  handler          = "saver.handler"
  runtime          = "python3.9"
  filename         = data.archive_file.saver_zip.output_path
  source_code_hash = data.archive_file.saver_zip.output_base64sha256
  timeout          = 10

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.uptime_results.name
      SNS_TOPIC_ARN  = aws_sns_topic.uptime_alert.arn
    }
  }
}

resource "aws_iam_role" "saver_role" {
  name = "WebsiteSaverRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "saver_policy" {
  name = "SaverPolicy"
  role = aws_iam_role.saver_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["dynamodb:PutItem"],
        Resource = aws_dynamodb_table.uptime_results.arn
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.uptime_alert.arn
      }
    ]
  })
}
