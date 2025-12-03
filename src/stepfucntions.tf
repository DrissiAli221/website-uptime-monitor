# deprecated (doesn't work with darwin_arm64)
# data "template_file" "state_workflow" {
#   template = file("${path.module}/src/state_machines/workflow.json")
#   vars = {
#     lambda_arn = aws_lambda_function_checker_function.arn
#   }
# }


resource "aws_sfn_state_machine" "uptime_checker" {
  name = "UptimeCheckerStateMachine"
  #   link the IAM role
  role_arn = aws_iam_role.sfn_executor_role.arn
  #   provide the workflow definition 
  #  definition = data.template_file.state_workflow.rendered (deprecated)
  #  new way 
  definition = templatefile("${path.module}/state_machines/workflow.json", {
    lambda_arn = aws_lambda_function.checker_function.arn
  })

}
