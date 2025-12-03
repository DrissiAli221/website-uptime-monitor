# the alarm clock (rule)
resource "aws_cloudwatch_event_rule" "five_minutes" {
  name                = "EveryFiveMinutes"
  schedule_expression = "rate(5 minutes)"

  # initially for testing its set to false
  # is_enabled = false deprecated
  state = "DISABLED"
}

# connects the rule to step function state machine (target)
resource "aws_cloudwatch_event_target" "sfc_target" {
  target_id = "TriggerStateMachine"
  rule      = aws_cloudwatch_event_rule.five_minutes.name
  #  ARN of the Step Function to trigger
  arn = aws_sfn_state_machine.uptime_checker.arn
  #   Forgot to link role !!
  role_arn = aws_iam_role.eventbridge_role.arn
  #   for now :
  input = jsonencode({
    "url" : "https://www.google.com"
  })
}
