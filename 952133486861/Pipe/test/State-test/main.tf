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

### EXTERNAL REFERENCES ###

data "aws_dynamodb_table" "Tablex-test" {
  name                              = "Tablex-test"
}




### CATEGORY: IAM ###

data "aws_iam_policy_document" "lambda_function_Functionx-test_st_State-test_doc" {
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources                       = ["${data.aws_dynamodb_table.Tablex-test.arn}", "${data.aws_dynamodb_table.Tablex-test.arn}/*"]
  }
}

resource "aws_iam_policy" "lambda_function_Functionx-test_st_State-test" {
  name                              = "lambda_function_Functionx-test_st_State-test"
  description                       = "Access Policy for Functionx-test"
  policy                            = data.aws_iam_policy_document.lambda_function_Functionx-test_st_State-test_doc.json
}

resource "aws_iam_role" "role_lambda_Functionx-test" {
  name                              = "role_lambda_Functionx-test"
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
    "Name" = "role_lambda_Functionx-test"
    "State" = "State-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_Functionx-test_st_State-test_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_Functionx-test_st_State-test.arn
  role                              = aws_iam_role.role_lambda_Functionx-test.name
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudMan_Functionx-test" {
  output_path                       = "${path.module}/CloudMan_Functionx-test.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Functionx-test" {
  function_name                     = "Functionx-test"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Functionx-test.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_Functionx-test.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Functionx-test.output_base64sha256}"
  timeout                           = 2
  environment {
    variables                       = {
    "AWS_DYNAMODB_TABLE_TARGET_NAME_0" = "Tablex-test"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "NAME" = "Functionx-test"
    "AWS_DYNAMODB_TABLE_TARGET_ARN_0" = data.aws_dynamodb_table.Tablex-test.arn
  }
  }
  tags                              = {
    "Name" = "Functionx-test"
    "State" = "State-test"
    "CloudmanUser" = "SystemUser"
    "Stage" = "test"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_Functionx-test_st_State-test_attach]
}


