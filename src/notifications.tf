resource "aws_sns_topic" "uptime_alert" {
  name = "WebsiteDownAlert"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.uptime_alert.arn
  protocol  = "email"
  endpoint  = "drissiali2004@gmail.com"
}
