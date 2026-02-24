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
    key            = "952133486861/State/main.tfstate"
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

resource "aws_iam_role" "role_lambda_Function" {
  name                              = "role_lambda_Function"
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
    "Name" = "role_lambda_Function"
    "State" = "State"
    "CloudmanUser" = "CloudMan2"
  }
}

resource "aws_iam_role" "role_lambda_Function1" {
  name                              = "role_lambda_Function1"
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
    "Name" = "role_lambda_Function1"
    "State" = "State"
    "CloudmanUser" = "CloudMan2"
  }
}




### CATEGORY: NETWORK ###

resource "aws_api_gateway_deployment" "Deploy1" {
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI.id
  lifecycle {
    create_before_destroy           = true
  }
  triggers                          = {
    "redeployment" = sha1(join(",", [jsonencode(aws_api_gateway_rest_api.RestAPI.body)]))
  }
}

resource "aws_api_gateway_rest_api" "RestAPI" {
  name                              = "RestAPI"
  tags                              = {
    "Name" = "RestAPI"
    "State" = "State"
    "CloudmanUser" = "CloudMan2"
  }
}

resource "aws_api_gateway_stage" "Stage" {
  deployment_id                     = aws_api_gateway_deployment.Deploy1.id
  rest_api_id                       = aws_api_gateway_rest_api.RestAPI.id
  stage_name                        = "prod"
  tags                              = {
    "Name" = "Stage"
    "State" = "State"
    "CloudmanUser" = "CloudMan2"
  }
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudMan_Function" {
  output_path                       = "${path.module}/CloudMan_Function.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function" {
  function_name                     = "Function"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  layers                            = ["arn:aws:lambda:us-east-1:952133486861:layer:PyJWTLayer-dev:3"]
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_Function.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "NAME" = "Function"
  }
  }
  tags                              = {
    "Name" = "Function"
    "State" = "State"
    "CloudmanUser" = "CloudMan2"
  }
}

data "archive_file" "archive_CloudMan_Function1" {
  output_path                       = "${path.module}/CloudMan_Function1.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "Function1" {
  function_name                     = "Function1"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_Function1.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_Function1.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function1.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "NAME" = "Function1"
  }
  }
  tags                              = {
    "Name" = "Function1"
    "State" = "State"
    "CloudmanUser" = "CloudMan2"
  }
}

resource "aws_lambda_permission" "perm_RestAPI_to_Function1_openapi" {
  function_name                     = aws_lambda_function.Function1.function_name
  statement_id                      = "perm_RestAPI_to_Function1_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.RestAPI.execution_arn}/*/POST/Function1"
}

resource "aws_lambda_permission" "perm_RestAPI_to_Function_openapi" {
  function_name                     = aws_lambda_function.Function.function_name
  statement_id                      = "perm_RestAPI_to_Function_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.RestAPI.execution_arn}/*/*/Function"
}


