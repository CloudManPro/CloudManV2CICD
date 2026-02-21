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
    key            = "952133486861/CDNMain/main.tfstate"
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

data "aws_cloudfront_cache_policy" "policy_cachingdisabled" {
  name                              = "Managed-CachingDisabled"
}




### EXTERNAL REFERENCES ###

data "aws_acm_certificate" "CloudManV2" {
  domain                            = "v2.cloudman.pro"
  most_recent                       = true
  statuses                          = ["ISSUED"]
}

data "aws_cognito_user_pools" "CloudManV2" {
  name = "CloudManV2"
}

data "aws_cognito_user_pool" "CloudManV2" {
  user_pool_id                      = data.aws_cognito_user_pools.CloudManV2.ids[0]
}




### CATEGORY: IAM ###

data "aws_iam_policy_document" "lambda_function_GetStageV2_st_CDNMain_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.GetStageV2.arn}:*"]
  }
  statement {
    sid                             = "AllowBucketLevelActions"
    effect                          = "Allow"
    actions                         = ["s3:DeleteObject", "s3:GetBucketLocation", "s3:GetObject", "s3:ListBucket", "s3:PutObject"]
    resources                       = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_GetStageV2_st_CDNMain" {
  name                              = "lambda_function_GetStageV2_st_CDNMain"
  description                       = "Access Policy for GetStageV2"
  policy                            = data.aws_iam_policy_document.lambda_function_GetStageV2_st_CDNMain_doc.json
}

data "aws_iam_policy_document" "lambda_function_RedirectorV2_st_CDNMain_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.RedirectorV2.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_RedirectorV2_st_CDNMain" {
  name                              = "lambda_function_RedirectorV2_st_CDNMain"
  description                       = "Access Policy for RedirectorV2"
  policy                            = data.aws_iam_policy_document.lambda_function_RedirectorV2_st_CDNMain_doc.json
}

resource "aws_iam_role" "role_lambda_GetStageV2" {
  name                              = "role_lambda_GetStageV2"
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
    "Name" = "role_lambda_GetStageV2"
    "State" = "CDNMain"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_lambda_RedirectorV2" {
  name                              = "role_lambda_RedirectorV2"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      }
    }
  ]
})
  tags                              = {
    "Name" = "role_lambda_RedirectorV2"
    "State" = "CDNMain"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_GetStageV2_st_CDNMain_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_GetStageV2_st_CDNMain.arn
  role                              = aws_iam_role.role_lambda_GetStageV2.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_RedirectorV2_st_CDNMain_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_RedirectorV2_st_CDNMain.arn
  role                              = aws_iam_role.role_lambda_RedirectorV2.name
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "alias_a_v2_to_AuthCloudManV2" {
  name                              = "v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "A"
  alias {
    name                            = aws_cloudfront_distribution.AuthCloudManV2.domain_name
    zone_id                         = aws_cloudfront_distribution.AuthCloudManV2.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa_v2_to_AuthCloudManV2" {
  name                              = "v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cloudfront_distribution.AuthCloudManV2.domain_name
    zone_id                         = aws_cloudfront_distribution.AuthCloudManV2.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_api_gateway_deployment" "APIAuthCloudManV2" {
  rest_api_id                       = aws_api_gateway_rest_api.APIAuthCloudManV2.id
  lifecycle {
    create_before_destroy           = true
  }
  triggers                          = {
    "redeployment" = sha1(join(",", [jsonencode(aws_api_gateway_rest_api.APIAuthCloudManV2.body)]))
  }
}

locals {
  api_config_APIAuthCloudManV2 = [
    {
      path             = "/GetStageV2"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:GetStageV2/invocations"
      type             = "aws_proxy"
      methods          = ["post"]
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
  ]
  openapi_spec_APIAuthCloudManV2 = {
        openapi = "3.0.1"
        info = {
        title   = "APIAuthCloudManV2"
        version = "1.0"
        }
        
        components = {
        securitySchemes = {
            "APIAuthCloudManV2_CognitoAuth" = {
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
        
        security = [
        { "APIAuthCloudManV2_CognitoAuth" = [] }
        ]
        paths = {
        for path in distinct([for i in local.api_config_APIAuthCloudManV2 : i.path]) :
        path => merge([
            for item in local.api_config_APIAuthCloudManV2 :
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

resource "aws_api_gateway_rest_api" "APIAuthCloudManV2" {
  name                              = "APIAuthCloudManV2"
  body                              = jsonencode(local.openapi_spec_APIAuthCloudManV2)
  endpoint_configuration {
    ip_address_type                 = "dualstack"
    types                           = ["REGIONAL"]
  }
  tags                              = {
    "Name" = "APIAuthCloudManV2"
    "State" = "CDNMain"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_api_gateway_stage" "st" {
  deployment_id                     = aws_api_gateway_deployment.APIAuthCloudManV2.id
  rest_api_id                       = aws_api_gateway_rest_api.APIAuthCloudManV2.id
  stage_name                        = "st"
  access_log_settings {
    destination_arn                 = aws_cloudwatch_log_group.APIAuthCloudManV2.arn
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
    "State" = "CDNMain"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_cloudfront_distribution" "AuthCloudManV2" {
  aliases                           = ["v2.cloudman.pro"]
  comment                           = "CloudMan Main V2"
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    target_origin_id                = "origin_AppBucket"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    compress                        = true
    default_ttl                     = 0
    max_ttl                         = 0
    min_ttl                         = 0
    viewer_protocol_policy          = "redirect-to-https"
    forwarded_values {
      headers                       = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      query_string                  = false
      cookies {
        forward                     = "whitelist"
        whitelisted_names           = ["stage"]
      }
    }
    lambda_function_association {
      event_type                    = "origin-request"
      include_body                  = false
      lambda_arn                    = aws_lambda_function.RedirectorV2.qualified_arn
    }
  }
  logging_config {
    bucket                          = aws_s3_bucket.auth-cloudman-v2-logs.bucket_domain_name
    include_cookies                 = false
  }
  ordered_cache_behavior {
    target_origin_id                = "origin_AppBucket"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    compress                        = true
    default_ttl                     = 300000
    max_ttl                         = 300000
    min_ttl                         = 300000
    path_pattern                    = "/_app/*"
    viewer_protocol_policy          = "redirect-to-https"
    forwarded_values {
      query_string                  = false
      cookies {
        forward                     = "whitelist"
        whitelisted_names           = ["stage"]
      }
    }
    lambda_function_association {
      event_type                    = "origin-request"
      include_body                  = false
      lambda_arn                    = aws_lambda_function.RedirectorV2.qualified_arn
    }
  }
  ordered_cache_behavior {
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingdisabled.id
    target_origin_id                = "origin_APIAuthCloudManV2"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    path_pattern                    = "/st/*"
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = aws_s3_bucket.s3-cloudmanv2-auth-bucket.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_s3-cloudmanv2-auth-bucket.id
    origin_id                       = "origin_AppBucket"
  }
  origin {
    domain_name                     = "${aws_api_gateway_rest_api.APIAuthCloudManV2.id}.execute-api.${data.aws_region.current.name}.amazonaws.com"
    origin_id                       = "origin_APIAuthCloudManV2"
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
    "Name" = "AuthCloudManV2"
    "State" = "CDNMain"
    "CloudmanUser" = "GlobalUserName"
  }
  viewer_certificate {
    acm_certificate_arn             = data.aws_acm_certificate.CloudManV2.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
  depends_on                        = [aws_s3_bucket_policy.aws_s3_bucket_policy_auth-cloudman-v2-logs_st_CDNMain]
}

resource "aws_cloudfront_origin_access_control" "oac_s3-cloudmanv2-auth-bucket" {
  name                              = "oac-s3-cloudmanv2-auth-bucket"
  description                       = "OAC for s3-cloudmanv2-auth-bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "auth-cloudman-v2-logs" {
  bucket                            = "auth-cloudman-v2-logs"
  force_destroy                     = false
  object_lock_enabled               = false
  tags                              = {
    "Name" = "auth-cloudman-v2-logs"
    "State" = "CDNMain"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket" "s3-cloudmanv2-auth-bucket" {
  bucket                            = "s3-cloudmanv2-auth-bucket"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "s3-cloudmanv2-auth-bucket"
    "State" = "CDNMain"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket_acl" "auth-cloudman-v2-logs_acl" {
  acl                               = "log-delivery-write"
  bucket                            = aws_s3_bucket.auth-cloudman-v2-logs.id
  depends_on                        = [aws_s3_bucket_ownership_controls.auth-cloudman-v2-logs_controls]
}

resource "aws_s3_bucket_ownership_controls" "auth-cloudman-v2-logs_controls" {
  bucket                            = aws_s3_bucket.auth-cloudman-v2-logs.id
  rule {
    object_ownership                = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3-cloudmanv2-auth-bucket_controls" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-auth-bucket.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_auth-cloudman-v2-logs_st_CDNMain_doc" {
  statement {
    sid                             = "AllowGetAcl"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetBucketAcl"]
    resources                       = ["${aws_s3_bucket.auth-cloudman-v2-logs.arn}"]
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
    resources                       = ["${aws_s3_bucket.auth-cloudman-v2-logs.arn}/*"]
    condition {
      test                          = "StringEquals"
      values                        = ["${data.aws_caller_identity.current.account_id}"]
      variable                      = "AWS:SourceAccount"
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_auth-cloudman-v2-logs_st_CDNMain" {
  bucket                            = aws_s3_bucket.auth-cloudman-v2-logs.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_auth-cloudman-v2-logs_st_CDNMain_doc.json
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_s3-cloudmanv2-auth-bucket_st_CDNMain_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.s3-cloudmanv2-auth-bucket.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.AuthCloudManV2.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_s3-cloudmanv2-auth-bucket_st_CDNMain" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-auth-bucket.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_s3-cloudmanv2-auth-bucket_st_CDNMain_doc.json
}

resource "aws_s3_bucket_public_access_block" "auth-cloudman-v2-logs_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.auth-cloudman-v2-logs.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_public_access_block" "s3-cloudmanv2-auth-bucket_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.s3-cloudmanv2-auth-bucket.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "auth-cloudman-v2-logs_configuration" {
  bucket                            = aws_s3_bucket.auth-cloudman-v2-logs.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-cloudmanv2-auth-bucket_configuration" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-auth-bucket.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "auth-cloudman-v2-logs_versioning" {
  bucket                            = aws_s3_bucket.auth-cloudman-v2-logs.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_s3_bucket_versioning" "s3-cloudmanv2-auth-bucket_versioning" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-auth-bucket.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudManMainV2_GetStageV2" {
  output_path                       = "${path.module}/CloudManMainV2_GetStageV2.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/GetStageV2"
  type                              = "zip"
}

resource "aws_lambda_function" "GetStageV2" {
  function_name                     = "GetStageV2"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_GetStageV2.output_path}"
  handler                           = "GetStageV2.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_GetStageV2.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_GetStageV2.output_base64sha256}"
  timeout                           = 2
  environment {
    variables                       = {
    "DOMAIN" = "${data.aws_route53_zone.Cloudman.name}"
    "AWS_S3_BUCKET_TARGET_NAME_0" = "s3-cloudmanv2-auth-bucket"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "NAME" = "GetStageV2"
    "AWS_S3_BUCKET_TARGET_ARN_0" = aws_s3_bucket.s3-cloudmanv2-auth-bucket.arn
  }
  }
  tags                              = {
    "Name" = "GetStageV2"
    "State" = "CDNMain"
    "CloudmanUser" = "GlobalUserName"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_GetStageV2_st_CDNMain_attach]
}

data "archive_file" "archive_CloudManMainV2_RedirectorV2" {
  output_path                       = "${path.module}/CloudManMainV2_RedirectorV2.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/Redirector"
  type                              = "zip"
}

resource "aws_lambda_function" "RedirectorV2" {
  function_name                     = "RedirectorV2"
  architectures                     = ["x86_64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_RedirectorV2.output_path}"
  handler                           = "Redirector.lambda_handler"
  memory_size                       = 128
  publish                           = true
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_RedirectorV2.arn
  runtime                           = "python3.12"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_RedirectorV2.output_base64sha256}"
  timeout                           = 1
  tags                              = {
    "Name" = "RedirectorV2"
    "State" = "CDNMain"
    "CloudmanUser" = "GlobalUserName"
  }
  timeouts {
    delete                          = "20m"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_RedirectorV2_st_CDNMain_attach]
}

resource "aws_lambda_permission" "perm_APIAuthCloudManV2_to_GetStageV2_openapi" {
  function_name                     = aws_lambda_function.GetStageV2.function_name
  statement_id                      = "perm_APIAuthCloudManV2_to_GetStageV2_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.APIAuthCloudManV2.execution_arn}/*/POST/GetStageV2"
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "APIAuthCloudManV2" {
  name                              = "/aws/apigateway/APIAuthCloudManV2"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "APIAuthCloudManV2"
    "State" = "CDNMain"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_cloudwatch_log_group" "GetStageV2" {
  name                              = "/aws/lambda/GetStageV2"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "GetStageV2"
    "State" = "CDNMain"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_cloudwatch_log_group" "RedirectorV2" {
  name                              = "/aws/lambda/RedirectorV2"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "RedirectorV2"
    "State" = "CDNMain"
    "CloudmanUser" = "GlobalUserName"
  }
}


