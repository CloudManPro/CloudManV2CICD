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
    key            = "952133486861/Main/main.tfstate"
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

data "aws_s3_bucket" "s3-cloudmanv2-files" {
  bucket                            = "s3-cloudmanv2-files"
}

data "aws_dynamodb_table" "CloudManV2" {
  name                              = "CloudManV2"
}




### CATEGORY: IAM ###

data "aws_iam_policy_document" "lambda_function_DBAccessV2_st_Main_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.DBAccessV2.arn}:*"]
  }
  statement {
    sid                             = "AllowDynamoDBCRUD"
    effect                          = "Allow"
    actions                         = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources                       = ["${data.aws_dynamodb_table.CloudManV2.arn}", "${data.aws_dynamodb_table.CloudManV2.arn}/*"]
  }
  statement {
    sid                             = "AllowBucketLevelActions"
    effect                          = "Allow"
    actions                         = ["s3:DeleteObject", "s3:GetBucketLocation", "s3:GetObject", "s3:ListBucket", "s3:PutObject"]
    resources                       = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_DBAccessV2_st_Main" {
  name                              = "lambda_function_DBAccessV2_st_Main"
  description                       = "Access Policy for DBAccessV2"
  policy                            = data.aws_iam_policy_document.lambda_function_DBAccessV2_st_Main_doc.json
}

data "aws_iam_policy_document" "lambda_function_HCLAWSV2_st_Main_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.HCLAWSV2.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_HCLAWSV2_st_Main" {
  name                              = "lambda_function_HCLAWSV2_st_Main"
  description                       = "Access Policy for HCLAWSV2"
  policy                            = data.aws_iam_policy_document.lambda_function_HCLAWSV2_st_Main_doc.json
}

resource "aws_iam_role" "role_lambda_DBAccessV2" {
  name                              = "role_lambda_DBAccessV2"
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
    "Name" = "role_lambda_DBAccessV2"
    "State" = "Main"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role" "role_lambda_HCLAWSV2" {
  name                              = "role_lambda_HCLAWSV2"
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
    "Name" = "role_lambda_HCLAWSV2"
    "State" = "Main"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_DBAccessV2_st_Main_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_DBAccessV2_st_Main.arn
  role                              = aws_iam_role.role_lambda_DBAccessV2.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_HCLAWSV2_st_Main_attach" {
  policy_arn                        = aws_iam_policy.lambda_function_HCLAWSV2_st_Main.arn
  role                              = aws_iam_role.role_lambda_HCLAWSV2.name
}

resource "aws_acm_certificate" "CloudManV2Dev" {
  domain_name                       = "dev.v2.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "Name" = "CloudManV2Dev"
    "State" = "Main"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_acm_certificate_validation" "Validation_CloudManV2Dev" {
  certificate_arn                   = aws_acm_certificate.CloudManV2Dev.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_CloudManV2Dev : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "Route53_Record_CloudManV2Dev" {
  for_each                          = {for dvo in aws_acm_certificate.CloudManV2Dev.domain_validation_options : dvo.domain_name => {
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

resource "aws_route53_record" "alias_a_dev_to_MainCloudManV2" {
  name                              = "dev.v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "A"
  alias {
    name                            = aws_cloudfront_distribution.MainCloudManV2.domain_name
    zone_id                         = aws_cloudfront_distribution.MainCloudManV2.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa_dev_to_MainCloudManV2" {
  name                              = "dev.v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cloudfront_distribution.MainCloudManV2.domain_name
    zone_id                         = aws_cloudfront_distribution.MainCloudManV2.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_api_gateway_deployment" "APICloudManV2" {
  rest_api_id                       = aws_api_gateway_rest_api.APICloudManV2.id
  lifecycle {
    create_before_destroy           = true
  }
  triggers                          = {
    "redeployment" = sha1(join(",", [jsonencode(aws_api_gateway_rest_api.APICloudManV2.body)]))
  }
}

locals {
  api_config_APICloudManV2 = [
    {
      path             = "/DBAccessV2"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:DBAccessV2/invocations"
      type             = "aws_proxy"
      methods          = ["options", "post"]
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
    {
      path             = "/HCLAWSV2"
      uri              = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:HCLAWSV2/invocations"
      type             = "aws_proxy"
      methods          = ["options", "post"]
      enable_mock      = true
      credentials      = null
      requestTemplates = null
      integ_method     = "POST"
      parameters       = null
      integ_req_params = null
    },
  ]

  openapi_spec_APICloudManV2 = {
    openapi = "3.0.1"
    info = {
      title   = "APICloudManV2"
      version = "1.0"
    }

    # --- CORREÇÃO 1: Gateway Responses para erros 4xx/5xx (ex: Cognito Unauthorized) ---
    "x-amazon-apigateway-gateway-responses" = {
      DEFAULT_4XX = {
        responseParameters = {
          "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
          "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
          "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept'"
        }
      }
      DEFAULT_5XX = {
        responseParameters = {
          "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
          "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
          "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept'"
        }
      }
    }

    components = {
      securitySchemes = {
        "ApiG_CognitoAuth" = {
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

    # Segurança Global (Aplica a todos os métodos por padrão)
    security = [
      { "ApiG_CognitoAuth" = [] }
    ]

    paths = {
      for path in distinct([for i in local.api_config_APICloudManV2 : i.path]) :
      path => merge([
        for item in local.api_config_APICloudManV2 :
        merge(
          {
            for method in item.methods :
            method => merge(
              {
                "responses" = {
                  "200" = {
                    description = "Successful operation"
                    headers = {
                      "Access-Control-Allow-Origin" = { type = "string" }
                    }
                  }
                }
                "x-amazon-apigateway-integration" = merge(
                  {
                    uri        = item.uri
                    httpMethod = item.integ_method == "MATCH" ? upper(method) : item.integ_method
                    type       = item.type
                  },
                  # Se for aws_proxy, a Lambda controla a resposta. Se não, o Gateway controla.
                  item.type == "aws_proxy" ? {} : {
                    responses = {
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
            if method != "options" # Pula OPTIONS aqui, pois tratamos ele separadamente abaixo
          },
          # --- CORREÇÃO 2: Configuração do MOCK de OPTIONS ---
          item.enable_mock ? {
            "options" = {
              summary = "CORS support"
              
              # IMPORTANTE: Sobrescreve a segurança global. O Preflight (OPTIONS) deve ser público.
              security = []
              
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
                      "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
                      # Adicionado Authorization e Accept para garantir que o navegador aceite
                      "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Accept'"
                      "method.response.header.Access-Control-Allow-Origin"  = "'*'"
                    }
                  }
                }
              }
            }
          } : {}
        )
        if item.path == path
      ]...)
    }
  }
}

resource "aws_api_gateway_rest_api" "APICloudManV2" {
  name                              = "APICloudManV2"
  body                              = jsonencode(local.openapi_spec_APICloudManV2)
  endpoint_configuration {
    ip_address_type                 = "dualstack"
    types                           = ["REGIONAL"]
  }
  tags                              = {
    "Name" = "APICloudManV2"
    "State" = "Main"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_api_gateway_stage" "st" {
  deployment_id                     = aws_api_gateway_deployment.APICloudManV2.id
  rest_api_id                       = aws_api_gateway_rest_api.APICloudManV2.id
  stage_name                        = "st"
  tags                              = {
    "Name" = "st"
    "State" = "Main"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_cloudfront_distribution" "MainCloudManV2" {
  aliases                           = ["dev.v2.cloudman.pro"]
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    target_origin_id                = "default_MainCloudManV2"
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
        forward                     = "all"
      }
    }
  }
  ordered_cache_behavior {
    target_origin_id                = "ordered_APICloudManV2"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    compress                        = false
    default_ttl                     = 0
    max_ttl                         = 0
    min_ttl                         = 0
    path_pattern                    = "/api-cloud-man-v2/*"
    viewer_protocol_policy          = "redirect-to-https"
    forwarded_values {
      query_string                  = false
      cookies {
        forward                     = "all"
      }
    }
  }
  origin {
    domain_name                     = aws_s3_bucket.s3-cloudmanv2-main-bucket.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_s3-cloudmanv2-main-bucket.id
    origin_id                       = "default_MainCloudManV2"
  }
  origin {
    domain_name                     = "${aws_api_gateway_rest_api.APICloudManV2.id}.execute-api.${data.aws_region.current.name}.amazonaws.com"
    origin_id                       = "ordered_APICloudManV2"
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
    "Name" = "MainCloudManV2"
    "State" = "Main"
    "CloudmanUser" = "GlobalUserName"
  }
  viewer_certificate {
    acm_certificate_arn             = aws_acm_certificate.CloudManV2Dev.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "oac_s3-cloudmanv2-main-bucket" {
  name                              = "oac-s3-cloudmanv2-main-bucket"
  description                       = "OAC for s3-cloudmanv2-main-bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "s3-cloudmanv2-main-bucket" {
  bucket                            = "s3-cloudmanv2-main-bucket"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "s3-cloudmanv2-main-bucket"
    "State" = "Main"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3-cloudmanv2-main-bucket_controls" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-main-bucket.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_s3-cloudmanv2-main-bucket_st_Main_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.s3-cloudmanv2-main-bucket.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.MainCloudManV2.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_s3-cloudmanv2-main-bucket_st_Main" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-main-bucket.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_s3-cloudmanv2-main-bucket_st_Main_doc.json
}

resource "aws_s3_bucket_public_access_block" "s3-cloudmanv2-main-bucket_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.s3-cloudmanv2-main-bucket.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-cloudmanv2-main-bucket_configuration" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-main-bucket.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = false
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "s3-cloudmanv2-main-bucket_versioning" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-main-bucket.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}




### CATEGORY: COMPUTE ###

data "archive_file" "archive_CloudManMainV2_DBAccessV2" {
  output_path                       = "${path.module}/CloudManMainV2_DBAccessV2.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/DBAccessV2"
  type                              = "zip"
}

resource "aws_lambda_function" "DBAccessV2" {
  function_name                     = "DBAccessV2"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_DBAccessV2.output_path}"
  handler                           = "DBAccessV2.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_DBAccessV2.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_DBAccessV2.output_base64sha256}"
  timeout                           = 3
  environment {
    variables                       = {
    "AWS_DYNAMODB_TABLE_TARGET_NAME_0" = "CloudManV2"
    "AWS_S3_BUCKET_TARGET_NAME_0" = "s3-cloudmanv2-files"
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "NAME" = "DBAccessV2"
    "AWS_S3_BUCKET_TARGET_ARN_0" = data.aws_s3_bucket.s3-cloudmanv2-files.arn
  }
  }
  tags                              = {
    "Name" = "DBAccessV2"
    "State" = "Main"
    "CloudmanUser" = "GlobalUserName"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_DBAccessV2_st_Main_attach]
}

data "archive_file" "archive_CloudManMainV2_HCLAWSV2" {
  output_path                       = "${path.module}/CloudManMainV2_HCLAWSV2.zip"
  source_dir                        = "${path.module}/.external_modules/CloudManMainV2/LambdaFiles/HCLAWSV2"
  type                              = "zip"
}

resource "aws_lambda_function" "HCLAWSV2" {
  function_name                     = "HCLAWSV2"
  architectures                     = ["arm64"]
  filename                          = "${data.archive_file.archive_CloudManMainV2_HCLAWSV2.output_path}"
  handler                           = "HCLAWSV2.lambda_handler"
  memory_size                       = 1024
  publish                           = false
  reserved_concurrent_executions    = -1
  role                              = aws_iam_role.role_lambda_HCLAWSV2.arn
  runtime                           = "python3.13"
  source_code_hash                  = "${data.archive_file.archive_CloudManMainV2_HCLAWSV2.output_base64sha256}"
  timeout                           = 5
  environment {
    variables                       = {
    "REGION" = data.aws_region.current.name
    "ACCOUNT" = data.aws_caller_identity.current.account_id
    "NAME" = "HCLAWSV2"
  }
  }
  tags                              = {
    "Name" = "HCLAWSV2"
    "State" = "Main"
    "CloudmanUser" = "GlobalUserName"
  }
  depends_on                        = [aws_iam_role_policy_attachment.lambda_function_HCLAWSV2_st_Main_attach]
}

resource "aws_lambda_permission" "perm_APICloudManV2_to_DBAccessV2_openapi" {
  function_name                     = aws_lambda_function.DBAccessV2.function_name
  statement_id                      = "perm_APICloudManV2_to_DBAccessV2_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.APICloudManV2.execution_arn}/*/*/DBAccessV2"
}

resource "aws_lambda_permission" "perm_APICloudManV2_to_HCLAWSV2_openapi" {
  function_name                     = aws_lambda_function.HCLAWSV2.function_name
  statement_id                      = "perm_APICloudManV2_to_HCLAWSV2_openapi"
  principal                         = "apigateway.amazonaws.com"
  action                            = "lambda:InvokeFunction"
  source_arn                        = "${aws_api_gateway_rest_api.APICloudManV2.execution_arn}/*/*/HCLAWSV2"
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "DBAccessV2" {
  name                              = "/aws/lambda/DBAccessV2"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "DBAccessV2"
    "State" = "Main"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_cloudwatch_log_group" "HCLAWSV2" {
  name                              = "/aws/lambda/HCLAWSV2"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "HCLAWSV2"
    "State" = "Main"
    "CloudmanUser" = "GlobalUserName"
  }
}


