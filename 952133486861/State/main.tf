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

### EXTERNAL REFERENCES ###

data "aws_cognito_user_pools" "CloudManV2" {
  name = "CloudManV2"
}

data "aws_cognito_user_pool" "CloudManV2" {
  user_pool_id                      = data.aws_cognito_user_pools.CloudManV2.ids[0]
}




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

locals {
  api_config_RestAPI = [
    {
      path             = "/Function"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:Function/invocations"
      type             = "aws_proxy"
      methods          = ["put", "get", "post"]
      method_auth      = {"put" = "RestAPI_CognitoAuth_CloudManV2"}
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
    {
      path             = "/Function1"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:Function1/invocations"
      type             = "aws_proxy"
      methods          = ["post"]
      method_auth      = {"post" = "RestAPI_CognitoAuth_CloudManV2"}
      enable_mock      = false
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
  ]
  openapi_spec_RestAPI = {
      openapi = "3.0.1"
      info = {
        title   = "RestAPI"
        version = "1.0"
      }
      
      components = {
        securitySchemes = {
            "RestAPI_CognitoAuth_CloudManV2" = {
              type = "apiKey"
              name = "Authorization"
              in   = "header"
              "x-amazon-apigateway-authtype" = "cognito_user_pools"
              "x-amazon-apigateway-authorizer" = {
                type = "cognito_user_pools"
                providerARNs = [data.aws_cognito_user_pool.CloudManV2.arn]
              }
            }
        }
      }
      paths = {
        for path in distinct([for i in local.api_config_RestAPI : i.path]) :
        path => merge([
          for item in local.api_config_RestAPI :
          merge(
            {
              for method in toset(item.methods) :
              method => merge(
                {
                  "responses" = {
                    "200" = {
                      description = "Successful operation"
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
                item.parameters != null ? { parameters = item.parameters } : {},
                
                # ALTERAÇÃO CRUCIAL AQUI: Aplica a segurança SÓ SE o método exigir
                contains(keys(item.method_auth), method) ? {
                  security = [
                    { (item.method_auth[method]) = [] }
                  ]
                } : {}
              )
              if method != "options"
            },
            item.enable_mock ? { "options" = {
          summary  = "CORS support"
          security = []  # <--- CORREÇÃO 1: Anula o authorizer global para o OPTIONS
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
                  "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
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

resource "aws_api_gateway_rest_api" "RestAPI" {
  name                              = "RestAPI"
  body                              = jsonencode(local.openapi_spec_RestAPI)
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


