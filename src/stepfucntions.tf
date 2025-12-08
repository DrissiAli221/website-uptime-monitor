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
  definition = templatefile("${path.module}/state_machines/multi_region_workflow.json", {
    checker_us_arn = module.us_check.lambda_arn
    checker_eu_arn = module.eu_check.lambda_arn
    proxy_arn      = aws_lambda_function.proxy.arn
    saver_arn      = aws_lambda_function.saver.arn
  })

}
