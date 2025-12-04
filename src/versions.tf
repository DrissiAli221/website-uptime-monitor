terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-ali-monitor-app"
    key            = "monitor-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking-ali-monitor-app"
    encrypt        = true
  }

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
}
