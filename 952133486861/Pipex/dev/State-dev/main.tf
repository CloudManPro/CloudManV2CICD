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
    key            = "952133486861/Pipex/dev/State-dev/main.tfstate"
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

data "aws_dynamodb_table" "Tablex-dev" {
  name                              = "Tablex-dev"
}




### CATEGORY: IAM ###

data "aws_iam_policy_document" "lambda_function_Function1x-dev_st_State-dev_doc" {
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources                       = ["${data.aws_dynamodb_table.Tablex-dev.arn}", "${data.aws_dynamodb_table.Tablex-dev.arn}/*"]
  }
}

resource "aws_iam_policy" "lambda_function_Function1x-dev_st_State-dev" {
  name                              = "lambda_function_Function1x-dev_st_State-dev"
  description                       = "Access Policy for Function1x-dev"
  policy                            = data.aws_iam_policy_document.lambda_function_Function1x-dev_st_State-dev_doc.json
}

data "aws_iam_policy_document" "lambda_function_Functionx-dev_st_State-dev_doc" {
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources                       = ["${data.aws_dynamodb_table.Tablex-dev.arn}", "${data.aws_dynamodb_table.Tablex-dev.arn}/*"]
  }
}

resource "aws_iam_policy" "lambda_function_Functionx-dev_st_State-dev" {
  name                              = "lambda_function_Functionx-dev_st_State-dev"
  description                       = "Access Policy for Functionx-dev"
  policy                            = data.aws_iam_policy_document.lambda_function_Functionx-dev_st_State-dev_doc.json
}

resource "aws_iam_role" "role_lambda_Function1x-dev" {
  name                              = "role_lambda_Function1x-dev"
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
    "Name" = "role_lambda_Function1x-dev"
    "State" = "State-dev"
    "CloudmanUser" = "Ricardo"
    "Stage" = "dev"
  }
}

resource "aws_iam_role" "role_lambda_Functionx-dev" {
  name                              = "role_lambda_Functionx-dev"
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
    "Name" = "role_lambda_Functionx-dev"
    "State" = "State-dev"
    "CloudmanUser" = "Ricardo"
    "Stage" = "dev"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_Function1x-dev_st_State-dev_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_Function1x-dev_st_State-dev.arn
  role                              = aws_iam_role.role_lambda_Function1x-dev.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_Functionx-dev_st_State-dev_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_Functionx-dev_st_State-dev.arn
  role                              = aws_iam_role.role_lambda_Functionx-dev.name
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudMan_Function1x-dev" {
  output_path                       = "${path.module}/CloudMan_Function1x-dev.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function1x-dev" {
  function_name                     = "Function1x-dev"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function1x-dev.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_Function1x-dev.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function1x-dev.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "CICD_STAGE" = "dev"
    "NAME" = "Function1x-dev"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "AWS_DYNAMODB_TABLE_TARGET_NAME_0" = "Tablex-dev"
    "AWS_DYNAMODB_TABLE_TARGET_ARN_0" = data.aws_dynamodb_table.Tablex-dev.arn
  }
  }
  tags                              = {
    "Name" = "Function1x-dev"
    "State" = "State-dev"
    "CloudmanUser" = "Ricardo"
    "Stage" = "dev"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_Function1x-dev_st_State-dev_attach]
}

data "archive_file" "archive_CloudMan_Functionx-dev" {
  output_path                       = "${path.module}/CloudMan_Functionx-dev.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Functionx-dev" {
  function_name                     = "Functionx-dev"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Functionx-dev.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_Functionx-dev.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Functionx-dev.output_base64sha256}"
  timeout                           = 2
  environment {
    variables                       = {
    "CICD_STAGE" = "dev"
    "NAME" = "Functionx-dev"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "AWS_DYNAMODB_TABLE_TARGET_NAME_0" = "Tablex-dev"
    "AWS_DYNAMODB_TABLE_TARGET_ARN_0" = data.aws_dynamodb_table.Tablex-dev.arn
  }
  }
  tags                              = {
    "Name" = "Functionx-dev"
    "State" = "State-dev"
    "CloudmanUser" = "Ricardo"
    "Stage" = "dev"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_Functionx-dev_st_State-dev_attach]
}


