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
    key            = "952133486861/CloudManCallBack/main.tfstate"
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

data "aws_iam_policy_document" "lambda_function_CallBackGithub_st_CloudManCallBack_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.CallBackGithub.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_CallBackGithub_st_CloudManCallBack" {
  name                              = "lambda_function_CallBackGithub_st_CloudManCallBack"
  description                       = "Access Policy for CallBackGithub"
  policy                            = data.aws_iam_policy_document.lambda_function_CallBackGithub_st_CloudManCallBack_doc.json
}

resource "aws_iam_role" "role_lambda_CallBackGithub" {
  name                              = "role_lambda_CallBackGithub"
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
    "Name" = "role_lambda_CallBackGithub"
    "State" = "CloudManCallBack"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_CallBackGithub_st_CloudManCallBack_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_CallBackGithub_st_CloudManCallBack.arn
  role                              = aws_iam_role.role_lambda_CallBackGithub.name
}




### CATEGORY: NETWORK ###

resource "aws_api_gateway_deployment" "CloudManCallBack" {
  rest_api_id                       = aws_api_gateway_rest_api.CloudManCallBack.id
  lifecycle {
    create_before_destroy           = true
  }
  triggers                          = {
    "redeployment" = sha1(join(",", [jsonencode(aws_api_gateway_rest_api.CloudManCallBack.body)]))
  }
}

locals {
  api_config_CloudManCallBack = [
    {
      path             = "/CallBackGithub"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:CallBackGithub/invocations"
      type             = "aws_proxy"
      methods          = ["post"]
      enable_mock      = false
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
  ]
  openapi_spec_CloudManCallBack = {
        openapi = "3.0.1"
        info = {
        title   = "CloudManCallBack"
        version = "1.0"
        }
        
        
        paths = {
        for path in distinct([for i in local.api_config_CloudManCallBack : i.path]) :
        path => merge([
            for item in local.api_config_CloudManCallBack :
            merge(
            {
                for method in item.methods :
                method => merge(
                {
                    "responses" = {
                    "200" = {
                        description = "Successful operation"
                        # Definimos que o header pode existir, mas não forçamos valor aqui
                        headers = {
                        "Access-Control-Allow-Origin" = { type = "string" }
                        "Set-Cookie" = { type = "string" }
                        }
                    }
                    }
                    "x-amazon-apigateway-integration" = merge(
                    {
                        uri        = item.uri
                        httpMethod = item.integ_method == "MATCH" ? upper(method) : item.integ_method
                        type       = item.type
                    },
                    # ALTERAÇÃO AQUI: Só adicionamos o bloco 'responses' se NÃO for aws_proxy.
                    # No modo aws_proxy, a Lambda é responsável por retornar todos os headers.
                    item.type == "aws_proxy" ? {} : {
                        responses  = {
                        "default" = {
                            statusCode = "200"
                            responseParameters = {
                            "method.response.header.Access-Control-Allow-Origin" = "'*'"
                            }
                            responseTemplates = {
                            "application/json" = "$input.body"
                            }
                        }
                        }
                    },
                    item.credentials != null ? { credentials = item.credentials } : {},
                    item.requestTemplates != null ? { requestTemplates = item.requestTemplates } : {},
                    item.integ_req_params != null ? { requestParameters = item.integ_req_params } : {}
                    )
                },
                item.parameters != null ? { parameters = item.parameters } : {}
                )
                if method != "options"
            },
            item.enable_mock ? { "options" = {
          summary  = "CORS support"
          consumes = ["application/json"]
          produces = ["application/json"]
          responses = {
            "200" = {
              description = "200 response"
              headers = {
                "Access-Control-Allow-Origin"  = { type = "string" }
                "Access-Control-Allow-Methods" = { type = "string" }
                "Access-Control-Allow-Headers" = { type = "string" }
              }
            }
          }
          "x-amazon-apigateway-integration" = {
            type = "mock"
            requestTemplates = { "application/json" = "{\"statusCode\": 200}" }
            responses = {
              default = {
                statusCode = "200"
                responseParameters = {
                  "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
                  "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
                  "method.response.header.Access-Control-Allow-Origin"  = "'*'"
                }
              }
            }
          }
        } } : {}
            )
            if item.path == path
        ]...)
        }
    }
}

resource "aws_api_gateway_rest_api" "CloudManCallBack" {
  name                              = "CloudManCallBack"
  body                              = jsonencode(local.openapi_spec_CloudManCallBack)
  tags                              = {
    "Name" = "CloudManCallBack"
    "State" = "CloudManCallBack"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_api_gateway_stage" "st" {
  deployment_id                     = aws_api_gateway_deployment.CloudManCallBack.id
  rest_api_id                       = aws_api_gateway_rest_api.CloudManCallBack.id
  stage_name                        = "st"
  access_log_settings {
    destination_arn                 = aws_cloudwatch_log_group.CloudManCallBack-st.arn
    format                          = jsonencode({
        "requestId" = "$context.requestId"
        "ip" = "$context.identity.sourceIp"
        "caller" = "$context.identity.caller"
        "user" = "$context.identity.user"
        "requestTime" = "$context.requestTime"
        "httpMethod" = "$context.httpMethod"
        "resourcePath" = "$context.resourcePath"
        "status" = "$context.status"
        "protocol" = "$context.protocol"
        "responseLength" = "$context.responseLength"
      })
  }
  tags                              = {
    "Name" = "st"
    "State" = "CloudManCallBack"
    "CloudmanUser" = "GlobalUserName"
  }
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudManMainV2_CallBackGithub" {
  output_path                       = "${path.module}/CloudManMainV2_CallBackGithub.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/CallBackGithub"
  type                              = "zip"
}

resource "aws_lambda_function" "CallBackGithub" {
  function_name                     = "CallBackGithub"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_CallBackGithub.output_path}"
  handler                           = "CallBackGithub.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_CallBackGithub.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_CallBackGithub.output_base64sha256}"
  timeout                           = 5
  environment {
    variables                       = {
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "NAME" = "CallBackGithub"
  }
  }
  tags                              = {
    "Name" = "CallBackGithub"
    "State" = "CloudManCallBack"
    "CloudmanUser" = "GlobalUserName"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_CallBackGithub_st_CloudManCallBack_attach]
}

resource "aws_lambda_permission" "perm_CloudManCallBack_to_CallBackGithub_openapi" {
  function_name                     = aws_lambda_function.CallBackGithub.function_name
  statement_id                      = "perm_CloudManCallBack_to_CallBackGithub_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.CloudManCallBack.execution_arn}/*/POST/CallBackGithub"
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "CallBackGithub" {
  name                              = "/aws/lambda/CallBackGithub"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "CallBackGithub"
    "State" = "CloudManCallBack"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_cloudwatch_log_group" "CloudManCallBack-st" {
  name                              = "/aws/apigateway/CloudManCallBack-st"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "CloudManCallBack-st"
    "State" = "CloudManCallBack"
    "CloudmanUser" = "GlobalUserName"
  }
}


