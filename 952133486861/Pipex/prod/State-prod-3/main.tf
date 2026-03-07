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
    key            = "952133486861/Pipex/prod/State-prod-3/main.tfstate"
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

data "aws_dynamodb_table" "Tablex-prod" {
  name                              = "Tablex-prod"
}




### CATEGORY: IAM ###

data "aws_iam_policy_document" "lambda_function_Function1x-prod-3_st_State-prod-3_doc" {
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources                       = ["${data.aws_dynamodb_table.Tablex-prod.arn}", "${data.aws_dynamodb_table.Tablex-prod.arn}/*"]
  }
}

resource "aws_iam_policy" "lambda_function_Function1x-prod-3_st_State-prod-3" {
  name                              = "lambda_function_Function1x-prod-3_st_State-prod-3"
  description                       = "Access Policy for Function1x-prod-3"
  policy                            = data.aws_iam_policy_document.lambda_function_Function1x-prod-3_st_State-prod-3_doc.json
}

data "aws_iam_policy_document" "lambda_function_Functionx-prod-3_st_State-prod-3_doc" {
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources                       = ["${data.aws_dynamodb_table.Tablex-prod.arn}", "${data.aws_dynamodb_table.Tablex-prod.arn}/*"]
  }
}

resource "aws_iam_policy" "lambda_function_Functionx-prod-3_st_State-prod-3" {
  name                              = "lambda_function_Functionx-prod-3_st_State-prod-3"
  description                       = "Access Policy for Functionx-prod-3"
  policy                            = data.aws_iam_policy_document.lambda_function_Functionx-prod-3_st_State-prod-3_doc.json
}

resource "aws_iam_role" "role_lambda_Function1x-prod-3" {
  name                              = "role_lambda_Function1x-prod-3"
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
    "Name" = "role_lambda_Function1x-prod-3"
    "State" = "State-prod-3"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
}

resource "aws_iam_role" "role_lambda_Functionx-prod-3" {
  name                              = "role_lambda_Functionx-prod-3"
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
    "Name" = "role_lambda_Functionx-prod-3"
    "State" = "State-prod-3"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_Function1x-prod-3_st_State-prod-3_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_Function1x-prod-3_st_State-prod-3.arn
  role                              = aws_iam_role.role_lambda_Function1x-prod-3.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_Functionx-prod-3_st_State-prod-3_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_Functionx-prod-3_st_State-prod-3.arn
  role                              = aws_iam_role.role_lambda_Functionx-prod-3.name
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudMan_Function1x-prod-3" {
  output_path                       = "${path.module}/CloudMan_Function1x-prod-3.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function1x-prod-3" {
  function_name                     = "Function1x-prod-3"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function1x-prod-3.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_Function1x-prod-3.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function1x-prod-3.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "CICD_STAGE" = "prod"
    "NAME" = "Function1x-prod-3"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "AWS_DYNAMODB_TABLE_TARGET_NAME_0" = "Tablex-prod"
    "AWS_DYNAMODB_TABLE_TARGET_ARN_0" = data.aws_dynamodb_table.Tablex-prod.arn
  }
  }
  tags                              = {
    "Name" = "Function1x-prod-3"
    "State" = "State-prod-3"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_Function1x-prod-3_st_State-prod-3_attach]
}

data "archive_file" "archive_CloudMan_Functionx-prod-3" {
  output_path                       = "${path.module}/CloudMan_Functionx-prod-3.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Functionx-prod-3" {
  function_name                     = "Functionx-prod-3"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Functionx-prod-3.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_Functionx-prod-3.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Functionx-prod-3.output_base64sha256}"
  timeout                           = 2
  environment {
    variables                       = {
    "CICD_STAGE" = "prod"
    "NAME" = "Functionx-prod-3"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "AWS_DYNAMODB_TABLE_TARGET_NAME_0" = "Tablex-prod"
    "AWS_DYNAMODB_TABLE_TARGET_ARN_0" = data.aws_dynamodb_table.Tablex-prod.arn
  }
  }
  tags                              = {
    "Name" = "Functionx-prod-3"
    "State" = "State-prod-3"
    "CloudmanUser" = "SystemUser"
    "Stage" = "prod"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_Functionx-prod-3_st_State-prod-3_attach]
}


