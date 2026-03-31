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
    key            = "952133486861/StateEB/main.tfstate"
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

data "aws_iam_policy_document" "lambda_function_FunctionEB_st_StateEB_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.FunctionEB.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_FunctionEB_st_StateEB" {
  name                              = "lambda_function_FunctionEB_st_StateEB"
  description                       = "Access Policy for FunctionEB"
  policy                            = data.aws_iam_policy_document.lambda_function_FunctionEB_st_StateEB_doc.json
}

resource "aws_iam_role" "role_lambda_FunctionEB" {
  name                              = "role_lambda_FunctionEB"
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
    "Name" = "role_lambda_FunctionEB"
    "State" = "StateEB"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_FunctionEB_st_StateEB_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_FunctionEB_st_StateEB.arn
  role                              = aws_iam_role.role_lambda_FunctionEB.name
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudMan_FunctionEB" {
  output_path                       = "${path.module}/CloudMan_FunctionEB.zip"
  source_dir                        = "${path.module}/.external_modules/CloudMan/LambdaFiles/LambdaHub2"
  type                              = "zip"
}

resource "aws_lambda_function" "FunctionEB" {
  function_name                     = "FunctionEB"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudMan_FunctionEB.output_path}"
  handler                           = "LambdaHub2.lambda_handler"
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_FunctionEB.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_FunctionEB.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "NAME" = "FunctionEB"
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
  }
  }
  tags                              = {
    "Name" = "FunctionEB"
    "State" = "StateEB"
    "CloudmanUser" = "Ricardo"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_FunctionEB_st_StateEB_attach]
}

resource "aws_lambda_permission" "perm_Rule_to_FunctionEB" {
  function_name                     = aws_lambda_function.FunctionEB.function_name
  statement_id                      = "perm_Rule_to_FunctionEB"
  principal                         = "events.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = aws_cloudwatch_event_rule.Rule.arn
}




### CATEGORY: INTEGRATION ###

resource "aws_cloudwatch_event_rule" "Rule" {
  name                              = "Rule"
  schedule_expression               = "rate(1 minute)"
  state                             = "ENABLED"
  tags                              = {
    "Name" = "Rule"
    "State" = "StateEB"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_cloudwatch_event_target" "Target" {
  arn                               = aws_lambda_function.FunctionEB.arn 
  rule                              = aws_cloudwatch_event_rule.Rule.name
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "FunctionEB" {
  name                              = "/aws/lambda/FunctionEB"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "FunctionEB"
    "State" = "StateEB"
    "CloudmanUser" = "Ricardo"
  }
}


