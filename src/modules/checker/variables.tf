variable "function_name" {
  type = string
}

variable "dynamodb_table_name" {
  type = string
}

variable "dynamodb_table_arn" {
  type = string
}

variable "primary_region" {
  description = "Region where dynamodb table lives"
  type = string
}