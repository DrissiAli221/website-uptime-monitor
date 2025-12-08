# data "archive_file" "checker_lambda_zip" {
#   type        = "zip"
#   source_dir  = "${path.module}/checker"
#   output_path = "${path.module}/dist/checker.zip"
# }


# resource "aws_lambda_function" "checker_function" {
#   function_name = "WebsiteStatusChecker"
#   # Linking to the IAM role 
#   role = aws_iam_role.lambda_executor_role.arn

#   filename         = data.archive_file.checker_lambda_zip.output_path
#   source_code_hash = data.archive_file.checker_lambda_zip.output_base64sha256 # Detect changes 

#   handler = "checker.handler" # Name of the function 
#   runtime = "python3.9"
#   timeout = 15

#   # Database name
#   environment {
#     variables = {
#       DYNAMODB_TABLE = aws_dynamodb_table.uptime_results.name
#     }
#   }

# }
