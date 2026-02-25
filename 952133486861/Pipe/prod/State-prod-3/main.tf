terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "cloudan-v2-cicd"
    key            = "952133486861/Pipe/prod/State-prod-3/main.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: INTEGRATION ###

resource "aws_sns_topic" "Topicz-prod-3" {
  name                              = "Topicz-prod-3"
  tags                              = {
    "Name" = "Topicz-prod-3"
    "State" = "State-prod-3"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
}


