# US branch
module "us_check" {
  source = "./modules/checker"

  function_name       = "UptimeChecker-US"
  dynamodb_table_name = aws_dynamodb_table.uptime_results.name
  dynamodb_table_arn  = aws_dynamodb_table.uptime_results.arn
  primary_region      = "us-east-1"
}

#EU branch

module "eu_check" {
  source = "./modules/checker"

  # specify region !!!!
  providers = {
    aws = aws.eu
  }

  function_name       = "UptimeChecker-EU"
  dynamodb_table_name = aws_dynamodb_table.uptime_results.name
  dynamodb_table_arn  = aws_dynamodb_table.uptime_results.arn
  #   The DB is NOT in EU. It is still in US (otherwise it will crash)
  primary_region = "us-east-1"


}
