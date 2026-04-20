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
    key            = "952133486861/DNS/main.tfstate"
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




### CATEGORY: IAM ###

resource "aws_acm_certificate" "Certificate" {
  domain_name                       = "cog-auth.app.struct8.com"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  lifecycle {
    create_before_destroy           = true
    prevent_destroy                 = false
  }
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "Name" = "Certificate"
    "State" = "DNS"
    "Struct8User" = "Struc8"
  }
}

resource "aws_acm_certificate" "app-struct8-com" {
  domain_name                       = "app.struct8.com"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  lifecycle {
    create_before_destroy           = true
    prevent_destroy                 = false
  }
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "Name" = "app-struct8-com"
    "State" = "DNS"
    "Struct8User" = "Struc8"
  }
}

resource "aws_acm_certificate_validation" "Validation_Certificate" {
  certificate_arn                   = aws_acm_certificate.Certificate.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_Certificate_cog_auth_app_struct8_com : record.fqdn]
}

resource "aws_acm_certificate_validation" "Validation_app-struct8-com" {
  certificate_arn                   = aws_acm_certificate.app-struct8-com.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_app-struct8-com_app_struct8_com : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "Route53_Record_Certificate_cog_auth_app_struct8_com" {
  for_each                          = {
    for dvo in aws_acm_certificate.Certificate.domain_validation_options : dvo.domain_name => dvo
    if dvo.domain_name == "cog-auth.app.struct8.com"
  }
  name                              = "${each.value.resource_record_name}"
  zone_id                           = data.aws_route53_zone.struct8.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.resource_record_value}"]
  ttl                               = 300
  type                              = "${each.value.resource_record_type}"
}

resource "aws_route53_record" "Route53_Record_app-struct8-com_app_struct8_com" {
  for_each                          = {
    for dvo in aws_acm_certificate.app-struct8-com.domain_validation_options : dvo.domain_name => dvo
    if dvo.domain_name == "app.struct8.com"
  }
  name                              = "${each.value.resource_record_name}"
  zone_id                           = data.aws_route53_zone.struct8.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.resource_record_value}"]
  ttl                               = 300
  type                              = "${each.value.resource_record_type}"
}


