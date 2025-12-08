terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~>2.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-bucket-ali-monitor-app"
    key            = "monitor-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking-ali-monitor-app"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Ireland
provider "aws" {
  region = "eu-west-1"
  alias  = "eu"
}

