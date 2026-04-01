terraform {
	required_providers {
		aws = {
		source = "hashicorp/aws"
		}
	}
	backend "s3" {
		bucket = "cloudan-v2-cicd"
		key    = "952133486861/StateLambdaImport/main.tfstate"
		region = "us-east-1"
	}
	}

	provider "aws" {
	region = "us-east-1"
	}

	resource "aws_iam_role" "TestImport_TestImport_role_23fxbua9" {
  assume_role_policy = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  managed_policy_arns = ["arn:aws:iam::952133486861:policy/service-role/AWSLambdaBasicExecutionRole-28fd3c45-f0df-4ffe-a540-8443a57969b4"]
  max_session_duration = 3600
  name = "TestImport-role-23fxbua9"
  path = "/service-role/"
}

resource "aws_lambda_function" "TestImport" {
  architectures = ["arm64"]
  ephemeral_storage {
    size = 512
  }
  function_name = "TestImport"
  handler = "lambda_function.lambda_handler"
  logging_config {
    log_format = "Text"
    log_group = "/aws/lambda/TestImport"
  }
  memory_size = 128
  package_type = "Zip"
  reserved_concurrent_executions = -1
  role = "arn:aws:iam::952133486861:role/service-role/TestImport-role-23fxbua9"
  runtime = "python3.14"
  s3_bucket = "cloudman-import-placeholder-bucket"
  s3_key = "imported-lambda-code.zip"
  tags = {
    Name = "TestImport"
  }
  timeout = 3
  tracing_config {
    mode = "PassThrough"
  }
  lifecycle {
    ignore_changes = [s3_bucket, s3_key, filename, image_uri, source_code_hash, publish]
  }
}

