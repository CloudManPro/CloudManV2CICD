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
    key            = "952133486861/Auth1/main.tfstate"
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




### CATEGORY: IAM ###

resource "aws_acm_certificate" "Certificate1" {
  domain_name                       = "new.cog-auth.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "Name" = "Certificate1"
    "State" = "Auth1"
    "CloudmanUser" = "CloudMan2"
  }
}

resource "aws_acm_certificate_validation" "Validation_Certificate1" {
  certificate_arn                   = aws_acm_certificate.Certificate1.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_Certificate1 : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "Route53_Record_Certificate1" {
  for_each                          = {for dvo in aws_acm_certificate.Certificate1.domain_validation_options : dvo.domain_name => {
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

resource "aws_route53_record" "alias_a_new_to_CloudManV1" {
  name                              = "new.cog-auth.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "A"
  alias {
    name                            = aws_cognito_user_pool_domain.CloudManV1.cloudfront_distribution
    zone_id                         = aws_cognito_user_pool_domain.CloudManV1.cloudfront_distribution_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa_new_to_CloudManV1" {
  name                              = "new.cog-auth.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cognito_user_pool_domain.CloudManV1.cloudfront_distribution
    zone_id                         = aws_cognito_user_pool_domain.CloudManV1.cloudfront_distribution_zone_id
    evaluate_target_health          = false
  }
}




### CATEGORY: MISC ###

resource "aws_cognito_user_pool" "CloudManV1" {
  name                              = "CloudManV1"
  auto_verified_attributes          = ["email"]
  deletion_protection               = "INACTIVE"
  mfa_configuration                 = "OFF"
  password_policy {
    minimum_length                  = 8
    require_lowercase               = true
    require_numbers                 = true
    require_symbols                 = true
    require_uppercase               = true
    temporary_password_validity_days = 7
  }
  schema {
    name                            = "name"
    attribute_data_type             = "String"
    developer_only_attribute        = false
    mutable                         = false
    required                        = true
    string_attribute_constraints {
      max_length                    = "40"
      min_length                    = "3"
    }
  }
  schema {
    name                            = "stage"
    attribute_data_type             = "String"
    developer_only_attribute        = false
    mutable                         = true
    required                        = false
    string_attribute_constraints {
      max_length                    = "40"
      min_length                    = "3"
    }
  }
  schema {
    name                            = "permit_log"
    attribute_data_type             = "Boolean"
    developer_only_attribute        = false
    mutable                         = true
    required                        = false
  }
  schema {
    name                            = "isV2"
    attribute_data_type             = "Boolean"
    developer_only_attribute        = false
    mutable                         = true
    required                        = false
  }
  sign_in_policy {
    allowed_first_auth_factors      = ["PASSWORD"]
  }
  tags                              = {
    "Name" = "CloudManV1"
    "State" = "Auth1"
    "CloudmanUser" = "CloudMan2"
  }
  username_configuration {
    case_sensitive                  = true
  }
  verification_message_template {
    default_email_option            = "CONFIRM_WITH_LINK"
    email_message_by_link           = "Click the link below to verify your email. {##Click Here##}"
    email_subject_by_link           = "CloudMan sign up confirmation"
  }
}

resource "aws_cognito_user_pool_client" "CloudManV1" {
  name                              = "CloudManV1"
  user_pool_id                      = aws_cognito_user_pool.CloudManV1.id
  access_token_validity             = 12
  allowed_oauth_flows               = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes              = ["openid", "email", "profile"]
  auth_session_validity             = 3
  callback_urls                     = ["https://v2.cloudman.pro"]
  enable_propagate_additional_user_context_data = false
  enable_token_revocation           = true
  explicit_auth_flows               = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
  generate_secret                   = false
  id_token_validity                 = 12
  logout_urls                       = ["https://v2.cloudman.pro"]
  prevent_user_existence_errors     = "ENABLED"
  refresh_token_validity            = 12
  supported_identity_providers      = ["COGNITO"]
  lifecycle {
    create_before_destroy           = false
    prevent_destroy                 = false
  }
  token_validity_units {
    access_token                    = "hours"
    id_token                        = "hours"
    refresh_token                   = "hours"
  }
}

resource "aws_cognito_user_pool_domain" "CloudManV1" {
  user_pool_id                      = aws_cognito_user_pool.CloudManV1.id
  certificate_arn                   = aws_acm_certificate.Certificate1.arn
  domain                            = "new.cog-auth.cloudman.pro"
  depends_on                        = [aws_acm_certificate_validation.Validation_Certificate1]
}


