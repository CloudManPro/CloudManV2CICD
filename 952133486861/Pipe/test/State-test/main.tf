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
    key            = "952133486861/Pipe/test/State-test/main.tfstate"
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

resource "aws_sns_topic" "Topicz-test" {
  name                              = "Topicz-test.fifo"
  content_based_deduplication       = true
  fifo_throughput_scope             = "Topic"
  fifo_topic                        = true
  signature_version                 = 2
  tags                              = {
    "Name" = "Topicz-test"
    "State" = "State-test"
    "CloudmanUser" = "Ricardo"
    "Stage" = "test"
  }
}


