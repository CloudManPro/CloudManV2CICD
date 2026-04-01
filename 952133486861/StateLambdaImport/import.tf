terraform {
  backend "s3" {
    bucket = "cloudan-v2-cicd"
    key    = "952133486861/StateLambdaImport/main.tfstate"
    region = "us-east-1"
  }
}

import {
  to = aws_cloudwatch_log_group.TestImport
  id = "TestImport"
}

import {
  to = aws_lambda_function.TestImport
  id = "TestImport"
}

import {
  to = aws_iam_role.TestImport_TestImport_role_23fxbua9
  id = "TestImport-role-23fxbua9"
}

