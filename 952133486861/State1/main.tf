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
    key            = "952133486861/State1/main.tfstate"
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

### CATEGORY: STORAGE ###

resource "aws_dynamodb_table" "Table" {
  name                              = "Table"
  billing_mode                      = "PROVISIONED"
  deletion_protection_enabled       = false
  hash_key                          = "ID"
  read_capacity                     = 1
  stream_enabled                    = false
  table_class                       = "STANDARD"
  write_capacity                    = 1
  tags                              = {
    "Name" = "Table"
    "State" = "State1"
    "CloudmanUser" = "Ricardo"
  }
}


