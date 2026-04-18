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

data "aws_route53_zone" "Cloudman" {
  name                              = "cloudman.pro"
}

data "aws_route53_zone" "struct8" {
  name                              = "struct8.com"
}




### CATEGORY: IAM ###

resource "aws_acm_certificate" "Certificate" {
  domain_name                       = "cog-auth.cloudman.pro"
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

resource "aws_acm_certificate" "Certificate1" {
  domain_name                       = "app.struct8.com"
  key_algorithm                     = "RSA_2048"
  subject_alternative_names         = ["v2.cloudman.pro"]
  validation_method                 = "DNS"
  lifecycle {
    create_before_destroy           = true
    prevent_destroy                 = false
  }
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "Name" = "Certificate1"
    "State" = "DNS"
    "Struct8User" = "Struc8"
  }
}

resource "aws_acm_certificate" "CloudManV2" {
  domain_name                       = "v2.cloudman.pro"
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
    "Name" = "CloudManV2"
    "State" = "DNS"
    "Struct8User" = "Struc8"
  }
}

resource "aws_acm_certificate_validation" "Validation_Certificate" {
  certificate_arn                   = aws_acm_certificate.Certificate.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_Certificate_cog_auth_cloudman_pro : record.fqdn]
}

resource "aws_acm_certificate_validation" "Validation_Certificate1" {
  certificate_arn                   = aws_acm_certificate.Certificate1.arn
  validation_record_fqdns           = concat(
    [for record in aws_route53_record.Route53_Record_Certificate1_app_struct8_com : record.fqdn],
    [for record in aws_route53_record.Route53_Record_Certificate1_v2_cloudman_pro : record.fqdn],
  )
}

resource "aws_acm_certificate_validation" "Validation_CloudManV2" {
  certificate_arn                   = aws_acm_certificate.CloudManV2.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_CloudManV2_v2_cloudman_pro : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "Route53_Record_Certificate1_app_struct8_com" {
  for_each                          = {
    for dvo in aws_acm_certificate.Certificate1.domain_validation_options : dvo.domain_name => dvo
    if dvo.domain_name == "app.struct8.com"
  }
  name                              = "${each.value.resource_record_name}"
  zone_id                           = data.aws_route53_zone.struct8.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.resource_record_value}"]
  ttl                               = 300
  type                              = "${each.value.resource_record_type}"
}

resource "aws_route53_record" "Route53_Record_Certificate1_v2_cloudman_pro" {
  for_each                          = {
    for dvo in aws_acm_certificate.Certificate1.domain_validation_options : dvo.domain_name => dvo
    if dvo.domain_name == "v2.cloudman.pro"
  }
  name                              = "${each.value.resource_record_name}"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.resource_record_value}"]
  ttl                               = 300
  type                              = "${each.value.resource_record_type}"
}

resource "aws_route53_record" "Route53_Record_Certificate_cog_auth_cloudman_pro" {
  for_each                          = {
    for dvo in aws_acm_certificate.Certificate.domain_validation_options : dvo.domain_name => dvo
    if dvo.domain_name == "cog-auth.cloudman.pro"
  }
  name                              = "${each.value.resource_record_name}"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.resource_record_value}"]
  ttl                               = 300
  type                              = "${each.value.resource_record_type}"
}

resource "aws_route53_record" "Route53_Record_CloudManV2_v2_cloudman_pro" {
  for_each                          = {
    for dvo in aws_acm_certificate.CloudManV2.domain_validation_options : dvo.domain_name => dvo
    if dvo.domain_name == "v2.cloudman.pro"
  }
  name                              = "${each.value.resource_record_name}"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.resource_record_value}"]
  ttl                               = 300
  type                              = "${each.value.resource_record_type}"
}


