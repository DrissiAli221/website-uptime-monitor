resource "aws_dynamodb_table" "uptime_results" {
  name         = "UptimeResultDatabase"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Url"
  range_key    = "Timestamp"


  attribute {
    name = "Url"
    type = "S"
  }
  attribute {
    name = "Timestamp"
    type = "S"
  }

  tags = {
    Project = "WebsiteUptimeMonitor"
  }


}
