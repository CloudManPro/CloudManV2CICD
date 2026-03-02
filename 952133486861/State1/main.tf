terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: INTEGRATION ###

resource "aws_sns_topic" "Topic2" {
  name                              = "Topic2"
  tags                              = {
    "Name" = "Topic2"
    "State" = "State1"
    "CloudmanUser" = "CloudMan2"
  }
}


