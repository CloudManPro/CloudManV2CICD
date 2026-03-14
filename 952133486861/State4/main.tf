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
    key            = "952133486861/State4/main.tfstate"
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

data "aws_route53_zone" "CloudMan" {
  name                              = "cloudman.pro"
}




### CATEGORY: IAM ###

resource "aws_acm_certificate" "CertificateWP" {
  domain_name                       = "wp.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "Name" = "CertificateWP"
    "State" = "State4"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_acm_certificate_validation" "Validation_CertificateWP" {
  certificate_arn                   = aws_acm_certificate.CertificateWP.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_CertificateWP : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "Route53_Record_CertificateWP" {
  for_each                          = {for dvo in aws_acm_certificate.CertificateWP.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name,
      record = dvo.resource_record_value,
      type   = dvo.resource_record_type
    }}
  name                              = "${each.value.name}"
  zone_id                           = data.aws_route53_zone.CloudMan.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.record}"]
  ttl                               = 300
  type                              = "${each.value.type}"
}


