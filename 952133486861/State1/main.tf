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
    key            = "952133486861/State1/main.tfstate"
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

resource "aws_acm_certificate" "Certificate2" {
  domain_name                       = "v2.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "Name" = "Certificate2"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_acm_certificate_validation" "Validation_Certificate2" {
  certificate_arn                   = aws_acm_certificate.Certificate2.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_Certificate2 : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "Route53_Record_Certificate2" {
  for_each                          = {for dvo in aws_acm_certificate.Certificate2.domain_validation_options : dvo.domain_name => {
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

resource "aws_route53_record" "alias_a__to_CloudManV2" {
  name                              = "v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "A"
  alias {
    name                            = aws_cloudfront_distribution.CloudManV2.domain_name
    zone_id                         = aws_cloudfront_distribution.CloudManV2.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa__to_CloudManV2" {
  name                              = "v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cloudfront_distribution.CloudManV2.domain_name
    zone_id                         = aws_cloudfront_distribution.CloudManV2.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_cloudfront_distribution" "CloudManV2" {
  aliases                           = ["v2.cloudman.pro"]
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    target_origin_id                = "default_CloudManV2"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = aws_s3_bucket.my-bucket-cloudman-dev-para-teste.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_my-bucket-cloudman-dev-para-teste.id
    origin_id                       = "default_CloudManV2"
  }
  restrictions {
    geo_restriction {
      restriction_type              = "none"
    }
  }
  tags                              = {
    "Name" = "CloudManV2"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
  viewer_certificate {
    acm_certificate_arn             = aws_acm_certificate.Certificate2.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "oac_my-bucket-cloudman-dev-para-teste" {
  name                              = "oac-my-bucket-cloudman-dev-para-teste"
  description                       = "OAC for my-bucket-cloudman-dev-para-teste"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "my-bucket-cloudman-dev-para-teste" {
  bucket                            = "my-bucket-cloudman-dev-para-teste"
  force_destroy                     = false
  object_lock_enabled               = false
  tags                              = {
    "Name" = "my-bucket-cloudman-dev-para-teste"
    "State" = "State1"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket_ownership_controls" "my-bucket-cloudman-dev-para-teste_controls" {
  bucket                            = aws_s3_bucket.my-bucket-cloudman-dev-para-teste.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_my-bucket-cloudman-dev-para-teste_st_State1_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.my-bucket-cloudman-dev-para-teste.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.CloudManV2.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_my-bucket-cloudman-dev-para-teste_st_State1" {
  bucket                            = aws_s3_bucket.my-bucket-cloudman-dev-para-teste.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_my-bucket-cloudman-dev-para-teste_st_State1_doc.json
}

resource "aws_s3_bucket_public_access_block" "my-bucket-cloudman-dev-para-teste_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.my-bucket-cloudman-dev-para-teste.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my-bucket-cloudman-dev-para-teste_configuration" {
  bucket                            = aws_s3_bucket.my-bucket-cloudman-dev-para-teste.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
  }
}

resource "aws_s3_bucket_versioning" "my-bucket-cloudman-dev-para-teste_versioning" {
  bucket                            = aws_s3_bucket.my-bucket-cloudman-dev-para-teste.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}


