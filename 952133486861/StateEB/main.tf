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
    "State" = "StateEB"
    "CloudmanUser" = "Ricardo"
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
  memory_size                       = 3008
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_Function.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudMan_Function.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "NAME" = "Function"
    "REGION" = "${data.aws_region.current.name}"
    "ACCOUNT" = "${data.aws_caller_identity.current.account_id}"
  }
  }
  tags                              = {
    "Name" = "Function"
    "State" = "StateEB"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_lambda_permission" "perm_Rule_to_Function" {
  function_name                     = aws_lambda_function.Function.function_name
  statement_id                      = "perm_Rule_to_Function"
  principal                         = "events.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = aws_cloudwatch_event_rule.Rule.arn
}




### CATEGORY: INTEGRATION ###

resource "aws_sqs_queue" "Queue" {
  name                              = "Queue"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags                              = {
    "Name" = "Queue"
    "State" = "StateEB"
    "CloudmanUser" = "Ricardo"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_Queue_st_StateEB_doc" {
  statement {
    sid                             = "AllowEventBridgeToSendMessageToSQS"
    effect                          = "Allow"
    principals {
      identifiers                   = ["events.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["sqs:SendMessage"]
    resources                       = ["${aws_sqs_queue.Queue.arn}"]
    condition {
      test                          = "StringEquals"
      values                        = ["${aws_cloudwatch_event_rule.Rule.arn}"]
      variable                      = "AWS:SourceArn"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_Queue_st_StateEB" {
  policy                            = data.aws_iam_policy_document.aws_sqs_queue_policy_Queue_st_StateEB_doc.json
  queue_url                         = aws_sqs_queue.Queue.id
}

resource "aws_sns_topic" "Topic2" {
  name                              = "Topic2"
  tags                              = {
    "Name" = "Topic2"
    "State" = "StateEB"
    "CloudmanUser" = "Ricardo"
  }
}

data "aws_iam_policy_document" "aws_sns_topic_policy_Topic2_st_StateEB_doc" {
  statement {
    sid                             = "AllowEventBridgeToPublishToSNS"
    effect                          = "Allow"
    principals {
      identifiers                   = ["events.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["sns:Publish"]
    resources                       = ["${aws_sns_topic.Topic2.arn}"]
    condition {
      test                          = "StringEquals"
      values                        = ["${aws_cloudwatch_event_rule.Rule.arn}"]
      variable                      = "AWS:SourceArn"
    }
  }
}

resource "aws_sns_topic_policy" "aws_sns_topic_policy_Topic2_st_StateEB" {
  arn                               = aws_sns_topic.Topic2.arn
  policy                            = data.aws_iam_policy_document.aws_sns_topic_policy_Topic2_st_StateEB_doc.json
}

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
  arn                               = aws_sqs_queue.Queue.arn
  rule                              = aws_cloudwatch_event_rule.Rule.name
}

resource "aws_cloudwatch_event_target" "Target1" {
  arn                               = aws_sns_topic.Topic2.arn
  rule                              = aws_cloudwatch_event_rule.Rule.name
}

resource "aws_cloudwatch_event_target" "Target2" {
  arn                               = aws_lambda_function.Function.arn
  rule                              = aws_cloudwatch_event_rule.Rule.name
}


