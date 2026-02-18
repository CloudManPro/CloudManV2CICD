terraform {
  required_version = ">= 1.0.0"

  required_providers {
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

data "aws_cloudfront_cache_policy" "policy_cachingoptimized" {
  name                              = "Managed-CachingOptimized"
}




### CATEGORY: IAM ###

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

resource "aws_cloudfront_distribution" "MainCloudManV2" {
  aliases                           = ["dev.v2.cloudman.pro"]
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    target_origin_id                = "default_MainCloudManV2"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = aws_s3_bucket.s3-cloudmanv2-main-bucket.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_s3-cloudmanv2-main-bucket.id
    origin_id                       = "default_MainCloudManV2"
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
    bucket_key_enabled              = true
  }
}

resource "aws_s3_bucket_versioning" "s3-cloudmanv2-main-bucket_versioning" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-main-bucket.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}


