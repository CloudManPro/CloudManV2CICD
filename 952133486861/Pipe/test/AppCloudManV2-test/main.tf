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
    key            = "952133486861/Pipe/test/AppCloudManV2-test/main.tfstate"
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

data "aws_s3_bucket" "s3-cloudmanv2-files-test" {
  bucket                            = "s3-cloudmanv2-files-test"
}

data "aws_dynamodb_table" "CloudManV2-test" {
  name                              = "CloudManV2-test"
}

data "aws_ssm_parameter" "GitHubAppKeyProd" {
  name                              = "GitHubAppKeyProd"
}

data "aws_ssm_parameter" "GithubClientAndSecretProd" {
  name                              = "GithubClientAndSecretProd"
}




### CATEGORY: IAM ###

data "aws_iam_policy_document" "lambda_function_AgentV2-test_st_AppCloudManV2-test_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.AgentV2-test.arn}:*"]
  }
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources                       = ["${data.aws_dynamodb_table.CloudManV2-test.arn}", "${data.aws_dynamodb_table.CloudManV2-test.arn}/*"]
  }
  statement {
    sid                             = "AllowLambdaInvoke"
    effect                          = "Allow"
    actions                         = ["lambda:InvokeFunction"]
    resources                       = ["${aws_lambda_function.GithubGateKeeper-test.arn}"]
  }
  statement {
    sid                             = "AllowAllResources"
    effect                          = "Allow"
    actions                         = ["ce:GetCostAndUsage", "ec2:DescribeImages", "ec2:DescribeSpotPriceHistory", "pricing:GetProducts", "sts:AssumeRole", "tag:GetResources", "tag:TagResources", "tag:UntagResources"]
    resources                       = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_AgentV2-test_st_AppCloudManV2-test" {
  name                              = "lambda_function_AgentV2-test_st_AppCloudManV2-test"
  description                       = "Access Policy for AgentV2-test"
  policy                            = data.aws_iam_policy_document.lambda_function_AgentV2-test_st_AppCloudManV2-test_doc.json
}

data "aws_iam_policy_document" "lambda_function_DBAccessV2-test_st_AppCloudManV2-test_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.DBAccessV2-test.arn}:*"]
  }
  statement {
    sid                             = "AllowBucketLevelActions"
    effect                          = "Allow"
    actions                         = ["s3:DeleteObject", "s3:GetBucketLocation", "s3:GetObject", "s3:ListBucket", "s3:PutObject"]
    resources                       = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_DBAccessV2-test_st_AppCloudManV2-test" {
  name                              = "lambda_function_DBAccessV2-test_st_AppCloudManV2-test"
  description                       = "Access Policy for DBAccessV2-test"
  policy                            = data.aws_iam_policy_document.lambda_function_DBAccessV2-test_st_AppCloudManV2-test_doc.json
}

data "aws_iam_policy_document" "lambda_function_GithubGateKeeper-test_st_AppCloudManV2-test_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.GithubGateKeeper-test.arn}:*"]
  }
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources                       = ["${data.aws_dynamodb_table.CloudManV2-test.arn}", "${data.aws_dynamodb_table.CloudManV2-test.arn}/*"]
  }
  statement {
    sid                             = "AllowReadParam"
    effect                          = "Allow"
    actions                         = ["ssm:GetParameter", "ssm:GetParameters"]
    resources                       = ["${data.aws_ssm_parameter.GitHubAppKeyProd.arn}"]
  }
  statement {
    sid                             = "AllowReadParam1"
    effect                          = "Allow"
    actions                         = ["ssm:GetParameter", "ssm:GetParameters"]
    resources                       = ["${data.aws_ssm_parameter.GithubClientAndSecretProd.arn}"]
  }
}

resource "aws_iam_policy" "lambda_function_GithubGateKeeper-test_st_AppCloudManV2-test" {
  name                              = "lambda_function_GithubGateKeeper-test_st_AppCloudManV2-test"
  description                       = "Access Policy for GithubGateKeeper-test"
  policy                            = data.aws_iam_policy_document.lambda_function_GithubGateKeeper-test_st_AppCloudManV2-test_doc.json
}

data "aws_iam_policy_document" "lambda_function_HCLAWSV2-test_st_AppCloudManV2-test_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.HCLAWSV2-test.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_HCLAWSV2-test_st_AppCloudManV2-test" {
  name                              = "lambda_function_HCLAWSV2-test_st_AppCloudManV2-test"
  description                       = "Access Policy for HCLAWSV2-test"
  policy                            = data.aws_iam_policy_document.lambda_function_HCLAWSV2-test_st_AppCloudManV2-test_doc.json
}

resource "aws_iam_role" "role_lambda_AgentV2-test" {
  name                              = "role_lambda_AgentV2-test"
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
    "Name" = "role_lambda_AgentV2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_iam_role" "role_lambda_DBAccessV2-test" {
  name                              = "role_lambda_DBAccessV2-test"
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
    "Name" = "role_lambda_DBAccessV2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_iam_role" "role_lambda_GithubGateKeeper-test" {
  name                              = "role_lambda_GithubGateKeeper-test"
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
    "Name" = "role_lambda_GithubGateKeeper-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_iam_role" "role_lambda_HCLAWSV2-test" {
  name                              = "role_lambda_HCLAWSV2-test"
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
    "Name" = "role_lambda_HCLAWSV2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_AgentV2-test_st_AppCloudManV2-test_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_AgentV2-test_st_AppCloudManV2-test.arn
  role                              = aws_iam_role.role_lambda_AgentV2-test.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_DBAccessV2-test_st_AppCloudManV2-test_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_DBAccessV2-test_st_AppCloudManV2-test.arn
  role                              = aws_iam_role.role_lambda_DBAccessV2-test.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_GithubGateKeeper-test_st_AppCloudManV2-test_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_GithubGateKeeper-test_st_AppCloudManV2-test.arn
  role                              = aws_iam_role.role_lambda_GithubGateKeeper-test.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_HCLAWSV2-test_st_AppCloudManV2-test_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_HCLAWSV2-test_st_AppCloudManV2-test.arn
  role                              = aws_iam_role.role_lambda_HCLAWSV2-test.name
}

resource "aws_acm_certificate" "AppCloudManV2-test" {
  domain_name                       = "test.v2.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "Name" = "AppCloudManV2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_acm_certificate_validation" "Validation_AppCloudManV2-test" {
  certificate_arn                   = aws_acm_certificate.AppCloudManV2-test.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_AppCloudManV2-test : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "Route53_Record_AppCloudManV2-test" {
  for_each                          = {for dvo in aws_acm_certificate.AppCloudManV2-test.domain_validation_options : dvo.domain_name => {
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

resource "aws_route53_record" "alias_a_test-test_to_AppCloudManV2-test" {
  name                              = "test.v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "A"
  alias {
    name                            = aws_cloudfront_distribution.AppCloudManV2-test.domain_name
    zone_id                         = aws_cloudfront_distribution.AppCloudManV2-test.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa_test-test_to_AppCloudManV2-test" {
  name                              = "test.v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cloudfront_distribution.AppCloudManV2-test.domain_name
    zone_id                         = aws_cloudfront_distribution.AppCloudManV2-test.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_api_gateway_deployment" "APIAppCloudManV2-test" {
  rest_api_id                       = aws_api_gateway_rest_api.APIAppCloudManV2-test.id
  lifecycle {
    create_before_destroy           = true
  }
  triggers                          = {
    "redeployment" = sha1(join(",", [jsonencode(aws_api_gateway_rest_api.APIAppCloudManV2-test.body)]))
  }
}

locals {
  api_config_APIAppCloudManV2-test = [
    {
      path             = "/HCLAWSV2-test"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:HCLAWSV2-test/invocations"
      type             = "aws_proxy"
      methods          = ["post"]
      method_auth      = {"post" = "APIAppCloudManV2-test_CognitoAuth_CloudManV2"}
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
    {
      path             = "/DBAccessV2-test"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:DBAccessV2-test/invocations"
      type             = "aws_proxy"
      methods          = ["post"]
      method_auth      = {"post" = "APIAppCloudManV2-test_CognitoAuth_CloudManV2"}
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
    {
      path             = "/AgentV2-test"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:AgentV2-test/invocations"
      type             = "aws_proxy"
      methods          = ["post"]
      method_auth      = {"post" = "APIAppCloudManV2-test_CognitoAuth_CloudManV2"}
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
    {
      path             = "/GithubGateKeeper-test"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:GithubGateKeeper-test/invocations"
      type             = "aws_proxy"
      methods          = ["get", "post"]
      method_auth      = {}
      enable_mock      = false
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
  ]
  openapi_spec_APIAppCloudManV2-test = {
      openapi = "3.0.1"
      info = {
        title   = "APIAppCloudManV2-test"
        version = "1.0"
      }
      
      components = {
        securitySchemes = {
            "APIAppCloudManV2-test_CognitoAuth_CloudManV2" = {
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
        for path in distinct([for i in local.api_config_APIAppCloudManV2-test : i.path]) :
        path => merge([
          for item in local.api_config_APIAppCloudManV2-test :
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

resource "aws_api_gateway_rest_api" "APIAppCloudManV2-test" {
  name                              = "APIAppCloudManV2-test"
  body                              = jsonencode(local.openapi_spec_APIAppCloudManV2-test)
  endpoint_configuration {
    ip_address_type                 = "dualstack"
    types                           = ["REGIONAL"]
  }
  tags                              = {
    "Name" = "APIAppCloudManV2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_api_gateway_stage" "st-test" {
  deployment_id                     = aws_api_gateway_deployment.APIAppCloudManV2-test.id
  rest_api_id                       = aws_api_gateway_rest_api.APIAppCloudManV2-test.id
  stage_name                        = "st"
  access_log_settings {
    destination_arn                 = aws_cloudwatch_log_group.AppCloudManV2-ST-test.arn
    format                          = jsonencode({"requestId": "$context.requestId", "ip": "$context.identity.sourceIp", "caller": "$context.identity.caller", "user": "$context.identity.user", "requestTime": "$context.requestTime", "httpMethod": "$context.httpMethod", "resourcePath": "$context.resourcePath", "status": "$context.status", "protocol": "$context.protocol", "responseLength": "$context.responseLength"})
  }
  tags                              = {
    "Name" = "st-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_cloudfront_distribution" "AppCloudManV2-test" {
  aliases                           = ["test.v2.cloudman.pro"]
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    target_origin_id                = "origin_BucketApp-test"
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
    bucket                          = aws_s3_bucket.app-cloudman-v2-logs-test.bucket_domain_name
    include_cookies                 = false
  }
  ordered_cache_behavior {
    target_origin_id                = "origin_APIAppCloudManV2-test"
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
    domain_name                     = aws_s3_bucket.app-cloudman-v2-test.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_app-cloudman-v2-test.id
    origin_id                       = "origin_BucketApp-test"
  }
  origin {
    domain_name                     = "${aws_api_gateway_rest_api.APIAppCloudManV2-test.id}.execute-api.${data.aws_region.current.name}.amazonaws.com"
    origin_id                       = "origin_APIAppCloudManV2-test"
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
    "Name" = "AppCloudManV2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
  viewer_certificate {
    acm_certificate_arn             = aws_acm_certificate.AppCloudManV2-test.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
  depends_on                        = [aws_s3_bucket_policy.aws_s3_bucket_policy_app-cloudman-v2-logs-test_st_AppCloudManV2-test]
}

resource "aws_cloudfront_origin_access_control" "oac_app-cloudman-v2-test" {
  name                              = "oac-app-cloudman-v2-test"
  description                       = "OAC for app-cloudman-v2-test"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "app-cloudman-v2-logs-test" {
  bucket                            = "app-cloudman-v2-logs-test"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "app-cloudman-v2-logs-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_s3_bucket" "app-cloudman-v2-test" {
  bucket                            = "app-cloudman-v2-test"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "app-cloudman-v2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_s3_bucket_acl" "app-cloudman-v2-logs-test_acl" {
  acl                               = "log-delivery-write"
  bucket                            = aws_s3_bucket.app-cloudman-v2-logs-test.id
  depends_on                        = [aws_s3_bucket_ownership_controls.app-cloudman-v2-logs-test_controls]
}

resource "aws_s3_bucket_ownership_controls" "app-cloudman-v2-logs-test_controls" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-logs-test.id
  rule {
    object_ownership                = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_ownership_controls" "app-cloudman-v2-test_controls" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-test.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_app-cloudman-v2-logs-test_st_AppCloudManV2-test_doc" {
  statement {
    sid                             = "AllowGetAcl"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetBucketAcl"]
    resources                       = ["${aws_s3_bucket.app-cloudman-v2-logs-test.arn}"]
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
    resources                       = ["${aws_s3_bucket.app-cloudman-v2-logs-test.arn}/*"]
    condition {
      test                          = "StringEquals"
      values                        = ["${data.aws_caller_identity.current.account_id}"]
      variable                      = "AWS:SourceAccount"
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_app-cloudman-v2-logs-test_st_AppCloudManV2-test" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-logs-test.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_app-cloudman-v2-logs-test_st_AppCloudManV2-test_doc.json
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_app-cloudman-v2-test_st_AppCloudManV2-test_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.app-cloudman-v2-test.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.AppCloudManV2-test.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_app-cloudman-v2-test_st_AppCloudManV2-test" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-test.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_app-cloudman-v2-test_st_AppCloudManV2-test_doc.json
}

resource "aws_s3_bucket_public_access_block" "app-cloudman-v2-logs-test_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.app-cloudman-v2-logs-test.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_public_access_block" "app-cloudman-v2-test_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.app-cloudman-v2-test.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app-cloudman-v2-logs-test_configuration" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-logs-test.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = false
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app-cloudman-v2-test_configuration" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-test.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = false
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "app-cloudman-v2-logs-test_versioning" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-logs-test.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_s3_bucket_versioning" "app-cloudman-v2-test_versioning" {
  bucket                            = aws_s3_bucket.app-cloudman-v2-test.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudManMainV2_AgentV2-test" {
  output_path                       = "${path.module}/CloudManMainV2_AgentV2-test.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/AgentV2"
  type                              = "zip"
}

resource "aws_lambda_function" "AgentV2-test" {
  function_name                     = "AgentV2-test"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_AgentV2-test.output_path}"
  handler                           = "AgentV2.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_AgentV2-test.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_AgentV2-test.output_base64sha256}"
  timeout                           = 30
  environment {
    variables                       = {
    "CICD_STAGE" = "test"
    "NAME" = "AgentV2-test"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "AWS_LAMBDA_FUNCTION_TARGET_NAME_0" = "GithubGateKeeper-test"
    "AWS_DYNAMODB_TABLE_TARGET_NAME_0" = "CloudManV2-test"
    "AWS_LAMBDA_FUNCTION_TARGET_ARN_0" = aws_lambda_function.GithubGateKeeper-test.arn
    "AWS_DYNAMODB_TABLE_TARGET_ARN_0" = data.aws_dynamodb_table.CloudManV2-test.arn
  }
  }
  tags                              = {
    "Name" = "AgentV2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_AgentV2-test_st_AppCloudManV2-test_attach]
}

data "archive_file" "archive_CloudManMainV2_DBAccessV2-test" {
  output_path                       = "${path.module}/CloudManMainV2_DBAccessV2-test.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/DBAccessV2"
  type                              = "zip"
}

resource "aws_lambda_function" "DBAccessV2-test" {
  function_name                     = "DBAccessV2-test"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_DBAccessV2-test.output_path}"
  handler                           = "DBAccessV2.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_DBAccessV2-test.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_DBAccessV2-test.output_base64sha256}"
  timeout                           = 3
  environment {
    variables                       = {
    "CICD_STAGE" = "test"
    "NAME" = "DBAccessV2-test"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "AWS_S3_BUCKET_TARGET_NAME_0" = "s3-cloudmanv2-files-test"
    "AWS_S3_BUCKET_TARGET_ARN_0" = data.aws_s3_bucket.s3-cloudmanv2-files-test.arn
  }
  }
  lifecycle {
    create_before_destroy           = false
    ignore_changes                  = [filename]
    prevent_destroy                 = false
  }
  tags                              = {
    "Name" = "DBAccessV2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_DBAccessV2-test_st_AppCloudManV2-test_attach]
}

data "archive_file" "archive_CloudManMainV2_GithubGateKeeper-test" {
  output_path                       = "${path.module}/CloudManMainV2_GithubGateKeeper-test.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/GithubGateKeeper"
  type                              = "zip"
}

resource "aws_lambda_function" "GithubGateKeeper-test" {
  function_name                     = "GithubGateKeeper-test"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_GithubGateKeeper-test.output_path}"
  handler                           = "GithubGateKeeper.lambda_handler"
  layers                            = ["arn:aws:lambda:us-east-1:952133486861:layer:PyJWTLayer-dev:3"]
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_GithubGateKeeper-test.arn
  runtime                           = "python3.12"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_GithubGateKeeper-test.output_base64sha256}"
  timeout                           = 10
  environment {
    variables                       = {
    "CLOUDMAN_CICD_STAGE" = "dev"
    "APP_URL" = "v2.cloudman.pro"
    "CICD_STAGE" = "test"
    "NAME" = "GithubGateKeeper-test"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "AWS_DYNAMODB_TABLE_TARGET_NAME_0" = "CloudManV2-test"
    "AWS_SSM_PARAMETER_TARGET_NAME_APPKEY" = "GitHubAppKeyProd"
    "AWS_SSM_PARAMETER_TARGET_NAME_SECRET" = "GithubClientAndSecretProd"
    "AWS_DYNAMODB_TABLE_TARGET_ARN_0" = data.aws_dynamodb_table.CloudManV2-test.arn
  }
  }
  tags                              = {
    "Name" = "GithubGateKeeper-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_GithubGateKeeper-test_st_AppCloudManV2-test_attach]
}

data "archive_file" "archive_CloudManMainV2_HCLAWSV2-test" {
  output_path                       = "${path.module}/CloudManMainV2_HCLAWSV2-test.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/HCLAWSV2"
  type                              = "zip"
}

resource "aws_lambda_function" "HCLAWSV2-test" {
  function_name                     = "HCLAWSV2-test"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_HCLAWSV2-test.output_path}"
  handler                           = "HCLAWSV2.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_HCLAWSV2-test.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_HCLAWSV2-test.output_base64sha256}"
  timeout                           = 5
  environment {
    variables                       = {
    "CICD_STAGE" = "test"
    "NAME" = "HCLAWSV2-test"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
  }
  }
  lifecycle {
    create_before_destroy           = false
    prevent_destroy                 = false
  }
  tags                              = {
    "Name" = "HCLAWSV2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_HCLAWSV2-test_st_AppCloudManV2-test_attach]
}

resource "aws_lambda_permission" "perm_APIAppCloudManV2-test_to_AgentV2-test_openapi" {
  function_name                     = aws_lambda_function.AgentV2-test.function_name
  statement_id                      = "perm_APIAppCloudManV2-test_to_AgentV2-test_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.APIAppCloudManV2-test.execution_arn}/*/POST/AgentV2-test"
}

resource "aws_lambda_permission" "perm_APIAppCloudManV2-test_to_DBAccessV2-test_openapi" {
  function_name                     = aws_lambda_function.DBAccessV2-test.function_name
  statement_id                      = "perm_APIAppCloudManV2-test_to_DBAccessV2-test_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.APIAppCloudManV2-test.execution_arn}/*/POST/DBAccessV2-test"
}

resource "aws_lambda_permission" "perm_APIAppCloudManV2-test_to_GithubGateKeeper-test_openapi" {
  function_name                     = aws_lambda_function.GithubGateKeeper-test.function_name
  statement_id                      = "perm_APIAppCloudManV2-test_to_GithubGateKeeper-test_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.APIAppCloudManV2-test.execution_arn}/*/*/GithubGateKeeper-test"
}

resource "aws_lambda_permission" "perm_APIAppCloudManV2-test_to_HCLAWSV2-test_openapi" {
  function_name                     = aws_lambda_function.HCLAWSV2-test.function_name
  statement_id                      = "perm_APIAppCloudManV2-test_to_HCLAWSV2-test_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.APIAppCloudManV2-test.execution_arn}/*/POST/HCLAWSV2-test"
}

resource "aws_lambda_permission" "perm_AgentV2-test_to_GithubGateKeeper-test" {
  function_name                     = aws_lambda_function.GithubGateKeeper-test.function_name
  statement_id                      = "perm_AgentV2-test_to_GithubGateKeeper-test"
  principal                         = "lambda.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = aws_lambda_function.AgentV2-test.arn
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "AgentV2-test" {
  name                              = "/aws/lambda/AgentV2-test"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "AgentV2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_cloudwatch_log_group" "AppCloudManV2-ST-test" {
  name                              = "/aws/apigateway/st-test"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "AppCloudManV2-ST-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_cloudwatch_log_group" "DBAccessV2-test" {
  name                              = "/aws/lambda/DBAccessV2-test"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "DBAccessV2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_cloudwatch_log_group" "GithubGateKeeper-test" {
  name                              = "/aws/lambda/GithubGateKeeper-test"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "GithubGateKeeper-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}

resource "aws_cloudwatch_log_group" "HCLAWSV2-test" {
  name                              = "/aws/lambda/HCLAWSV2-test"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "HCLAWSV2-test"
    "State" = "AppCloudManV2-test"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "test"
  }
}


