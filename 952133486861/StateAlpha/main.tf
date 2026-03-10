terraform {
  required_version = ">= 1.0.0"

  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "cloudan-v2-cicd"
    key            = "952133486861/StateAlpha/main.tfstate"
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

### CATEGORY: IAM ###

resource "aws_iam_role" "role_lambda_alphaX" {
  name                              = "role_lambda_alphaX"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
})
  tags                              = {
    "Name" = "role_lambda_alphaX"
    "State" = "StateAlpha"
    "CloudmanUser" = "Pro113"
  }
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudManMainV2_alphaX" {
  output_path                       = "${path.module}/CloudManMainV2_alphaX.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/GithubGateKeeper"
  type                              = "zip"
}

resource "aws_lambda_function" "alphaX" {
  function_name                     = "alphaX"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_alphaX.output_path}"
  handler                           = "GithubGateKeeper.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_alphaX.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_alphaX.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "NAME" = "alphaX"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
  }
  }
  tags                              = {
    "Name" = "alphaX"
    "State" = "StateAlpha"
    "CloudmanUser" = "Pro113"
  }
}




### CATEGORY: INTEGRATION ###

resource "aws_sns_topic" "AlphaX" {
  name                              = "AlphaX"
  tags                              = {
    "Name" = "AlphaX"
    "State" = "StateAlpha"
    "CloudmanUser" = "Pro113"
  }
}


