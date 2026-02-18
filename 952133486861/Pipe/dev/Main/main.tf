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
    key            = "952133486861/Pipe/dev/Main-dev/main.tfstate"
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

resource "aws_acm_certificate" "Certificate1-dev" {
  domain_name                       = "v2.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "Name" = "Certificate1-dev"
    "State" = "Main-dev"
    "CloudmanUser" = "GlobalUserName"
    "Stage" = "dev"
  }
}

resource "aws_acm_certificate_validation" "Validation_Certificate1-dev" {
  certificate_arn                   = aws_acm_certificate.Certificate1-dev.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_Certificate1-dev : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "Route53_Record_Certificate1-dev" {
  for_each                          = {for dvo in aws_acm_certificate.Certificate1-dev.domain_validation_options : dvo.domain_name => {
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

resource "aws_route53_record" "alias_a__to_MainCloudManV2-dev" {
  name                              = "v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "A"
  alias {
    name                            = aws_cloudfront_distribution.MainCloudManV2-dev.domain_name
    zone_id                         = aws_cloudfront_distribution.MainCloudManV2-dev.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa__to_MainCloudManV2-dev" {
  name                              = "v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cloudfront_distribution.MainCloudManV2-dev.domain_name
    zone_id                         = aws_cloudfront_distribution.MainCloudManV2-dev.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_cloudfront_distribution" "MainCloudManV2-dev" {
  aliases                           = ["v2.cloudman.pro"]
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    target_origin_id                = "default_MainCloudManV2-dev"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = aws_s3_bucket.s3-cloudmanv2-main-bucket-dev.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_s3-cloudmanv2-main-bucket-dev.id
    origin_id                       = "default_MainCloudManV2-dev"
  }
  restrictions {
    geo_restriction {
      restriction_type              = "none"
    }
  }
  tags                              = {
    "Name" = "MainCloudManV2-dev"
    "State" = "Main-dev"
    "CloudmanUser" = "GlobalUserName"
    "Stage" = "dev"
  }
  viewer_certificate {
    acm_certificate_arn             = aws_acm_certificate.Certificate1-dev.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "oac_s3-cloudmanv2-main-bucket-dev" {
  name                              = "oac-s3-cloudmanv2-main-bucket-dev"
  description                       = "OAC for s3-cloudmanv2-main-bucket-dev"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "s3-cloudmanv2-main-bucket-dev" {
  bucket                            = "s3-cloudmanv2-main-bucket"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "s3-cloudmanv2-main-bucket-dev"
    "State" = "Main-dev"
    "CloudmanUser" = "GlobalUserName"
    "Stage" = "dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3-cloudmanv2-main-bucket-dev_controls" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-main-bucket-dev.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_s3-cloudmanv2-main-bucket-dev_st_Main-dev_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.s3-cloudmanv2-main-bucket-dev.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.MainCloudManV2-dev.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_s3-cloudmanv2-main-bucket-dev_st_Main-dev" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-main-bucket-dev.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_s3-cloudmanv2-main-bucket-dev_st_Main-dev_doc.json
}

resource "aws_s3_bucket_public_access_block" "s3-cloudmanv2-main-bucket-dev_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.s3-cloudmanv2-main-bucket-dev.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-cloudmanv2-main-bucket-dev_configuration" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-main-bucket-dev.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
  }
}

resource "aws_s3_bucket_versioning" "s3-cloudmanv2-main-bucket-dev_versioning" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-main-bucket-dev.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}


