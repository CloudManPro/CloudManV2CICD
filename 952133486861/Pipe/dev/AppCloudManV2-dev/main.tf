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
    key            = "952133486861/Pipe/dev/AppCloudManV2-dev/main.tfstate"
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

### SYSTEM DATA SOURCES ###

data "aws_route53_zone" "Cloudman" {
  name                              = "cloudman.pro"
}




### EXTERNAL REFERENCES ###

data "aws_cognito_user_pools" "CloudManV2" {
  name = "CloudManV2"
}

data "aws_cognito_user_pool" "CloudManV2" {
  user_pool_id                      = data.aws_cognito_user_pools.CloudManV2.ids[0]
}

data "aws_s3_bucket" "s3-cloudmanv2-files-dev" {
  bucket                            = "s3-cloudmanv2-files-dev"
}

data "aws_dynamodb_table" "CloudManV2-dev" {
  name                              = "CloudManV2-dev"
}

data "aws_ssm_parameter" "GitHubAppKeyDev" {
  name                              = "GitHubAppKeyDev"
}

data "aws_ssm_parameter" "GithubClientAndSecret" {
  name                              = "GithubClientAndSecret"
}




### CATEGORY: IAM ###

data "aws_iam_policy_document" "lambda_function_AgentV2-dev_st_AppCloudManV2-dev_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.AgentV2-dev.arn}:*"]
  }
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources                       = ["${data.aws_dynamodb_table.CloudManV2-dev.arn}", "${data.aws_dynamodb_table.CloudManV2-dev.arn}/*"]
  }
  statement {
    sid                             = "AllowLambdaInvoke"
    effect                          = "Allow"
    actions                         = ["lambda:InvokeFunction"]
    resources                       = ["${aws_lambda_function.GithubGateKeeper-dev.arn}"]
  }
  statement {
    sid                             = "AllowAllResources"
    effect                          = "Allow"
    actions                         = ["ce:GetCostAndUsage", "ec2:DescribeImages", "ec2:DescribeSpotPriceHistory", "pricing:GetProducts", "sts:AssumeRole", "tag:GetResources", "tag:TagResources", "tag:UntagResources"]
    resources                       = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_AgentV2-dev_st_AppCloudManV2-dev" {
  name                              = "lambda_function_AgentV2-dev_st_AppCloudManV2-dev"
  description                       = "Access Policy for AgentV2-dev"
  policy                            = data.aws_iam_policy_document.lambda_function_AgentV2-dev_st_AppCloudManV2-dev_doc.json
}

data "aws_iam_policy_document" "lambda_function_DBAccessV2-dev_st_AppCloudManV2-dev_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.DBAccessV2-dev.arn}:*"]
  }
  statement {
    sid                             = "AllowBucketLevelActions"
    effect                          = "Allow"
    actions                         = ["s3:DeleteObject", "s3:GetBucketLocation", "s3:GetObject", "s3:ListBucket", "s3:PutObject"]
    resources                       = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_DBAccessV2-dev_st_AppCloudManV2-dev" {
  name                              = "lambda_function_DBAccessV2-dev_st_AppCloudManV2-dev"
  description                       = "Access Policy for DBAccessV2-dev"
  policy                            = data.aws_iam_policy_document.lambda_function_DBAccessV2-dev_st_AppCloudManV2-dev_doc.json
}

data "aws_iam_policy_document" "lambda_function_GithubGateKeeper-dev_st_AppCloudManV2-dev_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.GithubGateKeeper-dev.arn}:*"]
  }
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources                       = ["${data.aws_dynamodb_table.CloudManV2-dev.arn}", "${data.aws_dynamodb_table.CloudManV2-dev.arn}/*"]
  }
  statement {
    sid                             = "AllowReadParam"
    effect                          = "Allow"
    actions                         = ["ssm:GetParameter", "ssm:GetParameters"]
    resources                       = ["${data.aws_ssm_parameter.GitHubAppKeyDev.arn}"]
  }
  statement {
    sid                             = "AllowReadParam1"
    effect                          = "Allow"
    actions                         = ["ssm:GetParameter", "ssm:GetParameters"]
    resources                       = ["${data.aws_ssm_parameter.GithubClientAndSecret.arn}"]
  }
}

resource "aws_iam_policy" "lambda_function_GithubGateKeeper-dev_st_AppCloudManV2-dev" {
  name                              = "lambda_function_GithubGateKeeper-dev_st_AppCloudManV2-dev"
  description                       = "Access Policy for GithubGateKeeper-dev"
  policy                            = data.aws_iam_policy_document.lambda_function_GithubGateKeeper-dev_st_AppCloudManV2-dev_doc.json
}

data "aws_iam_policy_document" "lambda_function_HCLAWSV2-dev_st_AppCloudManV2-dev_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.HCLAWSV2-dev.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_HCLAWSV2-dev_st_AppCloudManV2-dev" {
  name                              = "lambda_function_HCLAWSV2-dev_st_AppCloudManV2-dev"
  description                       = "Access Policy for HCLAWSV2-dev"
  policy                            = data.aws_iam_policy_document.lambda_function_HCLAWSV2-dev_st_AppCloudManV2-dev_doc.json
}

resource "aws_iam_role" "role_lambda_AgentV2-dev" {
  name                              = "role_lambda_AgentV2-dev"
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
    "Name" = "role_lambda_AgentV2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_iam_role" "role_lambda_DBAccessV2-dev" {
  name                              = "role_lambda_DBAccessV2-dev"
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
    "Name" = "role_lambda_DBAccessV2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_iam_role" "role_lambda_GithubGateKeeper-dev" {
  name                              = "role_lambda_GithubGateKeeper-dev"
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
    "Name" = "role_lambda_GithubGateKeeper-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_iam_role" "role_lambda_HCLAWSV2-dev" {
  name                              = "role_lambda_HCLAWSV2-dev"
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
    "Name" = "role_lambda_HCLAWSV2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_AgentV2-dev_st_AppCloudManV2-dev_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_AgentV2-dev_st_AppCloudManV2-dev.arn
  role                              = aws_iam_role.role_lambda_AgentV2-dev.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_DBAccessV2-dev_st_AppCloudManV2-dev_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_DBAccessV2-dev_st_AppCloudManV2-dev.arn
  role                              = aws_iam_role.role_lambda_DBAccessV2-dev.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_GithubGateKeeper-dev_st_AppCloudManV2-dev_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_GithubGateKeeper-dev_st_AppCloudManV2-dev.arn
  role                              = aws_iam_role.role_lambda_GithubGateKeeper-dev.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_HCLAWSV2-dev_st_AppCloudManV2-dev_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_HCLAWSV2-dev_st_AppCloudManV2-dev.arn
  role                              = aws_iam_role.role_lambda_HCLAWSV2-dev.name
}

resource "aws_acm_certificate" "AppCloudManV2-dev" {
  domain_name                       = "dev.v2.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "Name" = "AppCloudManV2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_acm_certificate_validation" "Validation_AppCloudManV2-dev" {
  certificate_arn                   = aws_acm_certificate.AppCloudManV2-dev.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_AppCloudManV2-dev : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "Route53_Record_AppCloudManV2-dev" {
  for_each                          = {for dvo in aws_acm_certificate.AppCloudManV2-dev.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name,
      record = dvo.resource_record_value,
      type   = dvo.resource_record_type
    }}
  name                              = "${each.value.name}"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.record}"]
  ttl                               = 300
  type                              = "${each.value.type}"
}

resource "aws_route53_record" "alias_a_dev-dev_to_AppCloudManV2-dev" {
  name                              = "dev.v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "A"
  alias {
    name                            = aws_cloudfront_distribution.AppCloudManV2-dev.domain_name
    zone_id                         = aws_cloudfront_distribution.AppCloudManV2-dev.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa_dev-dev_to_AppCloudManV2-dev" {
  name                              = "dev.v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cloudfront_distribution.AppCloudManV2-dev.domain_name
    zone_id                         = aws_cloudfront_distribution.AppCloudManV2-dev.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_api_gateway_deployment" "APIAppCloudManV2-dev" {
  rest_api_id                       = aws_api_gateway_rest_api.APIAppCloudManV2-dev.id
  lifecycle {
    create_before_destroy           = true
  }
  triggers                          = {
    "redeployment" = sha1(join(",", [jsonencode(aws_api_gateway_rest_api.APIAppCloudManV2-dev.body)]))
  }
}

locals {
  api_config_APIAppCloudManV2-dev = [
    {
      path             = "/GithubGateKeeper-dev"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:GithubGateKeeper-dev/invocations"
      type             = "aws_proxy"
      methods          = ["post", "get"]
      method_auth      = {"get" = "APIAppCloudManV2-dev_CognitoAuth_CloudManV2", "post" = "APIAppCloudManV2-dev_CognitoAuth_CloudManV2"}
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
    {
      path             = "/HCLAWSV2-dev"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:HCLAWSV2-dev/invocations"
      type             = "aws_proxy"
      methods          = ["post", "get"]
      method_auth      = {"get" = "APIAppCloudManV2-dev_CognitoAuth_CloudManV2", "post" = "APIAppCloudManV2-dev_CognitoAuth_CloudManV2"}
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
    {
      path             = "/DBAccessV2-dev"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:DBAccessV2-dev/invocations"
      type             = "aws_proxy"
      methods          = ["post", "get"]
      method_auth      = {"get" = "APIAppCloudManV2-dev_CognitoAuth_CloudManV2", "post" = "APIAppCloudManV2-dev_CognitoAuth_CloudManV2"}
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
    {
      path             = "/AgentV2-dev"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:AgentV2-dev/invocations"
      type             = "aws_proxy"
      methods          = ["post", "get"]
      method_auth      = {"get" = "APIAppCloudManV2-dev_CognitoAuth_CloudManV2", "post" = "APIAppCloudManV2-dev_CognitoAuth_CloudManV2"}
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
  ]
  openapi_spec_APIAppCloudManV2-dev = {
      openapi = "3.0.1"
      info = {
        title   = "APIAppCloudManV2-dev"
        version = "1.0"
      }
      
      components = {
        securitySchemes = {
            "APIAppCloudManV2-dev_CognitoAuth_CloudManV2" = {
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
        for path in distinct([for i in local.api_config_APIAppCloudManV2-dev : i.path]) :
        path => merge([
          for item in local.api_config_APIAppCloudManV2-dev :
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
                  "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'"
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

resource "aws_api_gateway_rest_api" "APIAppCloudManV2-dev" {
  name                              = "APIAppCloudManV2-dev"
  body                              = jsonencode(local.openapi_spec_APIAppCloudManV2-dev)
  endpoint_configuration {
    ip_address_type                 = "dualstack"
    types                           = ["REGIONAL"]
  }
  tags                              = {
    "Name" = "APIAppCloudManV2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_api_gateway_stage" "st-dev" {
  deployment_id                     = aws_api_gateway_deployment.APIAppCloudManV2-dev.id
  rest_api_id                       = aws_api_gateway_rest_api.APIAppCloudManV2-dev.id
  stage_name                        = "st"
  access_log_settings {
    destination_arn                 = aws_cloudwatch_log_group.AppCloudManV2-ST-dev.arn
    format                          = jsonencode({"requestId": "$context.requestId", "ip": "$context.identity.sourceIp", "caller": "$context.identity.caller", "user": "$context.identity.user", "requestTime": "$context.requestTime", "httpMethod": "$context.httpMethod", "resourcePath": "$context.resourcePath", "status": "$context.status", "protocol": "$context.protocol", "responseLength": "$context.responseLength"})
  }
  tags                              = {
    "Name" = "st-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_cloudfront_distribution" "AppCloudManV2-dev" {
  aliases                           = ["dev.v2.cloudman.pro"]
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    target_origin_id                = "origin_BucketApp-dev"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    compress                        = true
    default_ttl                     = 86400
    max_ttl                         = 31536000
    min_ttl                         = 86400
    viewer_protocol_policy          = "redirect-to-https"
    forwarded_values {
      query_string                  = false
      cookies {
        forward                     = "whitelist"
        whitelisted_names           = ["stage"]
      }
    }
  }
  logging_config {
    bucket                          = aws_s3_bucket.app-cloudman-v2-logs-dev.bucket_domain_name
    include_cookies                 = false
  }
  ordered_cache_behavior {
    target_origin_id                = "origin_APIAppCloudManV2-dev"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    compress                        = true
    default_ttl                     = 0
    max_ttl                         = 0
    min_ttl                         = 0
    path_pattern                    = "/st/*"
    viewer_protocol_policy          = "redirect-to-https"
    forwarded_values {
      headers                       = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      query_string                  = true
      cookies {
        forward                     = "whitelist"
        whitelisted_names           = ["stage"]
      }
    }
  }
  origin {
    domain_name                     = aws_s3_bucket.app-cloudman-v2-dev.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_app-cloudman-v2-dev.id
    origin_id                       = "origin_BucketApp-dev"
  }
  origin {
    domain_name                     = "${aws_api_gateway_rest_api.APIAppCloudManV2-dev.id}.execute-api.${data.aws_region.current.name}.amazonaws.com"
    origin_id                       = "origin_APIAppCloudManV2-dev"
    custom_origin_config {
      http_port                     = 80
      https_port                    = 443
      origin_protocol_policy        = "https-only"
      origin_ssl_protocols          = ["TLSv1.2"]
    }
  }
  restrictions {
    geo_restriction {
      restriction_type              = "none"
    }
  }
  tags                              = {
    "Name" = "AppCloudManV2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
  viewer_certificate {
    acm_certificate_arn             = aws_acm_certificate.AppCloudManV2-dev.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
  depends_on                        = [aws_s3_bucket_policy.aws_s3_bucket_policy_app-cloudman-v2-logs-dev_st_AppCloudManV2-dev]
}

resource "aws_cloudfront_origin_access_control" "oac_app-cloudman-v2-dev" {
  name                              = "oac-app-cloudman-v2-dev"
  description                       = "OAC for app-cloudman-v2-dev"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "app-cloudman-v2-dev" {
  bucket                            = "app-cloudman-v2-dev"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "app-cloudman-v2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_s3_bucket" "app-cloudman-v2-logs-dev" {
  bucket                            = "app-cloudman-v2-logs-dev"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "app-cloudman-v2-logs-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_s3_bucket_acl" "app-cloudman-v2-logs-dev_acl" {
  acl                               = "log-delivery-write"
  bucket                            = aws_s3_bucket.app-cloudman-v2-logs-dev.id
  depends_on                        = [aws_s3_bucket_ownership_controls.app-cloudman-v2-logs-dev_controls]
}

resource "aws_s3_bucket_ownership_controls" "app-cloudman-v2-dev_controls" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-dev.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_ownership_controls" "app-cloudman-v2-logs-dev_controls" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-logs-dev.id
  rule {
    object_ownership                = "BucketOwnerPreferred"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_app-cloudman-v2-dev_st_AppCloudManV2-dev_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.app-cloudman-v2-dev.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.AppCloudManV2-dev.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_app-cloudman-v2-dev_st_AppCloudManV2-dev" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-dev.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_app-cloudman-v2-dev_st_AppCloudManV2-dev_doc.json
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_app-cloudman-v2-logs-dev_st_AppCloudManV2-dev_doc" {
  statement {
    sid                             = "AllowGetAcl"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetBucketAcl"]
    resources                       = ["${aws_s3_bucket.app-cloudman-v2-logs-dev.arn}"]
    condition {
      test                          = "StringEquals"
      values                        = ["${data.aws_caller_identity.current.account_id}"]
      variable                      = "AWS:SourceAccount"
    }
  }
  statement {
    sid                             = "AllowPutLogs"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:PutObject"]
    resources                       = ["${aws_s3_bucket.app-cloudman-v2-logs-dev.arn}/*"]
    condition {
      test                          = "StringEquals"
      values                        = ["${data.aws_caller_identity.current.account_id}"]
      variable                      = "AWS:SourceAccount"
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_app-cloudman-v2-logs-dev_st_AppCloudManV2-dev" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-logs-dev.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_app-cloudman-v2-logs-dev_st_AppCloudManV2-dev_doc.json
}

resource "aws_s3_bucket_public_access_block" "app-cloudman-v2-dev_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.app-cloudman-v2-dev.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_public_access_block" "app-cloudman-v2-logs-dev_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.app-cloudman-v2-logs-dev.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app-cloudman-v2-dev_configuration" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-dev.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = false
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app-cloudman-v2-logs-dev_configuration" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-logs-dev.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = false
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "app-cloudman-v2-dev_versioning" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-dev.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_s3_bucket_versioning" "app-cloudman-v2-logs-dev_versioning" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-logs-dev.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudManMainV2_AgentV2-dev" {
  output_path                       = "${path.module}/CloudManMainV2_AgentV2-dev.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/AgentV2"
  type                              = "zip"
}

resource "aws_lambda_function" "AgentV2-dev" {
  function_name                     = "AgentV2-dev"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_AgentV2-dev.output_path}"
  handler                           = "AgentV2.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_AgentV2-dev.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_AgentV2-dev.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "AWS_DYNAMODB_TABLE_TARGET_NAME_0" = "CloudManV2-dev"
    "AWS_LAMBDA_FUNCTION_TARGET_NAME_0" = "GithubGateKeeper-dev"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "NAME" = "AgentV2-dev"
    "AWS_DYNAMODB_TABLE_TARGET_ARN_0" = data.aws_dynamodb_table.CloudManV2-dev.arn
    "AWS_LAMBDA_FUNCTION_TARGET_ARN_0" = aws_lambda_function.GithubGateKeeper-dev.arn
  }
  }
  tags                              = {
    "Name" = "AgentV2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_AgentV2-dev_st_AppCloudManV2-dev_attach]
}

data "archive_file" "archive_CloudManMainV2_DBAccessV2-dev" {
  output_path                       = "${path.module}/CloudManMainV2_DBAccessV2-dev.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/DBAccessV2"
  type                              = "zip"
}

resource "aws_lambda_function" "DBAccessV2-dev" {
  function_name                     = "DBAccessV2-dev"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_DBAccessV2-dev.output_path}"
  handler                           = "DBAccessV2.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_DBAccessV2-dev.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_DBAccessV2-dev.output_base64sha256}"
  timeout                           = 3
  environment {
    variables                       = {
    "AWS_S3_BUCKET_TARGET_NAME_0" = "s3-cloudmanv2-files-dev"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "NAME" = "DBAccessV2-dev"
    "AWS_S3_BUCKET_TARGET_ARN_0" = data.aws_s3_bucket.s3-cloudmanv2-files-dev.arn
  }
  }
  lifecycle {
    create_before_destroy           = false
    ignore_changes                  = [filename]
    prevent_destroy                 = false
  }
  tags                              = {
    "Name" = "DBAccessV2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_DBAccessV2-dev_st_AppCloudManV2-dev_attach]
}

data "archive_file" "archive_CloudManMainV2_GithubGateKeeper-dev" {
  output_path                       = "${path.module}/CloudManMainV2_GithubGateKeeper-dev.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/GithubGateKeeper"
  type                              = "zip"
}

resource "aws_lambda_function" "GithubGateKeeper-dev" {
  function_name                     = "GithubGateKeeper-dev"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_GithubGateKeeper-dev.output_path}"
  handler                           = "GithubGateKeeper.lambda_handler"
  layers                            = ["arn:aws:lambda:us-east-1:952133486861:layer:PyJWTLayer-dev:3"]
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_GithubGateKeeper-dev.arn
  runtime                           = "python3.12"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_GithubGateKeeper-dev.output_base64sha256}"
  timeout                           = 10
  environment {
    variables                       = {
    "CLOUDMAN_CICD_STAGE" = "dev"
    "APP_URL" = "v2.cloudman.pro"
    "AWS_SSM_PARAMETER_TARGET_NAME_APPKEY" = "GitHubAppKeyDev"
    "AWS_SSM_PARAMETER_TARGET_NAME_SECRET" = "GithubClientAndSecret"
    "AWS_DYNAMODB_TABLE_TARGET_NAME_0" = "CloudManV2-dev"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "NAME" = "GithubGateKeeper-dev"
    "AWS_DYNAMODB_TABLE_TARGET_ARN_0" = data.aws_dynamodb_table.CloudManV2-dev.arn
  }
  }
  tags                              = {
    "Name" = "GithubGateKeeper-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_GithubGateKeeper-dev_st_AppCloudManV2-dev_attach]
}

data "archive_file" "archive_CloudManMainV2_HCLAWSV2-dev" {
  output_path                       = "${path.module}/CloudManMainV2_HCLAWSV2-dev.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/HCLAWSV2"
  type                              = "zip"
}

resource "aws_lambda_function" "HCLAWSV2-dev" {
  function_name                     = "HCLAWSV2-dev"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_HCLAWSV2-dev.output_path}"
  handler                           = "HCLAWSV2.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_HCLAWSV2-dev.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_HCLAWSV2-dev.output_base64sha256}"
  timeout                           = 5
  environment {
    variables                       = {
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "NAME" = "HCLAWSV2-dev"
  }
  }
  lifecycle {
    create_before_destroy           = false
    ignore_changes                  = [filename]
    prevent_destroy                 = false
  }
  tags                              = {
    "Name" = "HCLAWSV2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_HCLAWSV2-dev_st_AppCloudManV2-dev_attach]
}

resource "aws_lambda_permission" "perm_APIAppCloudManV2-dev_to_AgentV2-dev_openapi" {
  function_name                     = aws_lambda_function.AgentV2-dev.function_name
  statement_id                      = "perm_APIAppCloudManV2-dev_to_AgentV2-dev_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.APIAppCloudManV2-dev.execution_arn}/*/*/AgentV2-dev"
}

resource "aws_lambda_permission" "perm_APIAppCloudManV2-dev_to_DBAccessV2-dev_openapi" {
  function_name                     = aws_lambda_function.DBAccessV2-dev.function_name
  statement_id                      = "perm_APIAppCloudManV2-dev_to_DBAccessV2-dev_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.APIAppCloudManV2-dev.execution_arn}/*/*/DBAccessV2-dev"
}

resource "aws_lambda_permission" "perm_APIAppCloudManV2-dev_to_GithubGateKeeper-dev_openapi" {
  function_name                     = aws_lambda_function.GithubGateKeeper-dev.function_name
  statement_id                      = "perm_APIAppCloudManV2-dev_to_GithubGateKeeper-dev_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.APIAppCloudManV2-dev.execution_arn}/*/*/GithubGateKeeper-dev"
}

resource "aws_lambda_permission" "perm_APIAppCloudManV2-dev_to_HCLAWSV2-dev_openapi" {
  function_name                     = aws_lambda_function.HCLAWSV2-dev.function_name
  statement_id                      = "perm_APIAppCloudManV2-dev_to_HCLAWSV2-dev_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.APIAppCloudManV2-dev.execution_arn}/*/*/HCLAWSV2-dev"
}

resource "aws_lambda_permission" "perm_AgentV2-dev_to_GithubGateKeeper-dev" {
  function_name                     = aws_lambda_function.GithubGateKeeper-dev.function_name
  statement_id                      = "perm_AgentV2-dev_to_GithubGateKeeper-dev"
  principal                         = "lambda.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = aws_lambda_function.AgentV2-dev.arn
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "AgentV2-dev" {
  name                              = "/aws/lambda/AgentV2-dev"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "AgentV2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_cloudwatch_log_group" "AppCloudManV2-ST-dev" {
  name                              = "/aws/apigateway/st-dev"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "AppCloudManV2-ST-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_cloudwatch_log_group" "DBAccessV2-dev" {
  name                              = "/aws/lambda/DBAccessV2-dev"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "DBAccessV2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_cloudwatch_log_group" "GithubGateKeeper-dev" {
  name                              = "/aws/lambda/GithubGateKeeper-dev"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "GithubGateKeeper-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_cloudwatch_log_group" "HCLAWSV2-dev" {
  name                              = "/aws/lambda/HCLAWSV2-dev"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "HCLAWSV2-dev"
    "State" = "AppCloudManV2-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}


