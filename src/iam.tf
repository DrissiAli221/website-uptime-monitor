
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

data "aws_region" "current" {}


# State Functions IAM
# policy allows the Step Functions service to assume this role
resource "aws_iam_role" "sfn_executor_role" {
  name = "WebsiteUptimeStateMachineRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        # This allows Step Functions in my region to use this role
        Service = "states.amazonaws.com" # Use global service name instead of ${data.aws_region.current.name}
      }
      }
    ]
  })
}

# IAM Policy to allow invoking the specific lambda function
resource "aws_iam_policy" "sfn_lambda_invoke_policy" {
  name = "StepFunctionsLambdaInvokePolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "lambda:InvokeFunction"
      # Only grant permission to the specific Lambda function this workflow needs
      Resource = aws_lambda_function.checker_function.arn
    }]
  })
}

# Attach the policy to the role (watch out for swapping the two)
resource "aws_iam_role_policy_attachment" "sfn_lambda_attachment" {
  role       = aws_iam_role.sfn_executor_role.name
  policy_arn = aws_iam_policy.sfn_lambda_invoke_policy.arn
}





# Event Bridge IAM
resource "aws_iam_role" "eventbridge_role" {
  name = "EventBridgeStepFunctionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com" # events not event
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge_invoke_sfc" {
  name = "EventBridgeInvokeStepFunction"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "states:StartExecution"
        Resource = aws_sfn_state_machine.uptime_checker.arn
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eventbridge_sfn_attachement" {
  role       = aws_iam_role.eventbridge_role.name
  policy_arn = aws_iam_policy.eventbridge_invoke_sfc.arn
}




# Database Lambda IAM
resource "aws_iam_policy" "lambda_dynamo_policy" {
  name        = "LambdaDynamoDBWritePolicy"
  description = "Allows Lambda to write to DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "dynamodb:PutItem"
        #permission to this table alone
        Resource = aws_dynamodb_table.uptime_results.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamo_lambda_attachment" {
  role       = aws_iam_role.lambda_executor_role.name
  policy_arn = aws_iam_policy.lambda_dynamo_policy.arn
}
