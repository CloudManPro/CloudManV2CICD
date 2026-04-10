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
    key            = "952133486861/Struct8/main.tfstate"
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

data "aws_route53_zone" "struct8" {
  name                              = "struct8.com"
}

data "aws_cloudfront_origin_request_policy" "policy_cors_s3origin" {
  name                              = "Managed-CORS-S3Origin"
}

data "aws_cloudfront_cache_policy" "policy_cachingoptimized" {
  name                              = "Managed-CachingOptimized"
}




### CATEGORY: IAM ###

resource "aws_acm_certificate" "struc8" {
  domain_name                       = "struct8.com"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "Name" = "struc8"
    "State" = "Struct8"
    "CloudmanUser" = "CloudMan2"
  }
}

resource "aws_acm_certificate_validation" "Validation_struc8" {
  certificate_arn                   = aws_acm_certificate.struc8.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_struc8 : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "Route53_Record_struc8" {
  for_each                          = {for dvo in aws_acm_certificate.struc8.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name,
      record = dvo.resource_record_value,
      type   = dvo.resource_record_type
    }}
  name                              = "${each.value.name}"
  zone_id                           = data.aws_route53_zone.struct8.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.record}"]
  ttl                               = 300
  type                              = "${each.value.type}"
}

resource "aws_route53_record" "alias_a_aws_cloudfront_distribution_STRUCT8" {
  name                              = "struct8.com"
  zone_id                           = data.aws_route53_zone.struct8.zone_id
  type                              = "A"
  alias {
    name                            = aws_cloudfront_distribution.STRUCT8.domain_name
    zone_id                         = aws_cloudfront_distribution.STRUCT8.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa_aws_cloudfront_distribution_STRUCT8" {
  name                              = "struct8.com"
  zone_id                           = data.aws_route53_zone.struct8.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cloudfront_distribution.STRUCT8.domain_name
    zone_id                         = aws_cloudfront_distribution.STRUCT8.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_cloudfront_distribution" "STRUCT8" {
  aliases                           = ["struct8.com"]
  comment                           = "STRUCT8"
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    origin_request_policy_id        = data.aws_cloudfront_origin_request_policy.policy_cors_s3origin.id
    target_origin_id                = "origin_static-site"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = aws_s3_bucket.struc8-static-site.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_struc8-static-site.id
    origin_id                       = "origin_static-site"
  }
  restrictions {
    geo_restriction {
      restriction_type              = "none"
    }
  }
  tags                              = {
    "Name" = "STRUCT8"
    "State" = "Struct8"
    "CloudmanUser" = "CloudMan2"
  }
  viewer_certificate {
    acm_certificate_arn             = aws_acm_certificate.struc8.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "oac_struc8-static-site" {
  name                              = "oac-struc8-static-site"
  description                       = "OAC for struc8-static-site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "struc8-static-site" {
  bucket                            = "struc8-static-site"
  force_destroy                     = false
  object_lock_enabled               = false
  tags                              = {
    "Name" = "struc8-static-site"
    "State" = "Struct8"
    "CloudmanUser" = "CloudMan2"
  }
}

resource "aws_s3_bucket_ownership_controls" "struc8-static-site_controls" {
  bucket                            = aws_s3_bucket.struc8-static-site.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_struc8-static-site_st_Struct8_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.struc8-static-site.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.STRUCT8.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_struc8-static-site_st_Struct8" {
  bucket                            = aws_s3_bucket.struc8-static-site.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_struc8-static-site_st_Struct8_doc.json
}

resource "aws_s3_bucket_public_access_block" "struc8-static-site_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.struc8-static-site.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "struc8-static-site_configuration" {
  bucket                            = aws_s3_bucket.struc8-static-site.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
  }
}

resource "aws_s3_bucket_versioning" "struc8-static-site_versioning" {
  bucket                            = aws_s3_bucket.struc8-static-site.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}


