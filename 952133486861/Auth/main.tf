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
    key            = "952133486861/Auth/main.tfstate"
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

data "aws_acm_certificate" "Certificate" {
  domain                            = "cog-auth.cloudman.pro"
  most_recent                       = true
  statuses                          = ["ISSUED"]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "alias_a_cog-auth_to_CloudManV2" {
  name                              = "cog-auth.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "A"
  alias {
    name                            = aws_cognito_user_pool_domain.CloudManV2.cloudfront_distribution
    zone_id                         = aws_cognito_user_pool_domain.CloudManV2.cloudfront_distribution_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa_cog-auth_to_CloudManV2" {
  name                              = "cog-auth.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cognito_user_pool_domain.CloudManV2.cloudfront_distribution
    zone_id                         = aws_cognito_user_pool_domain.CloudManV2.cloudfront_distribution_zone_id
    evaluate_target_health          = false
  }
}




### CATEGORY: MISC ###

resource "aws_cognito_user_pool" "CloudManV2" {
  name                              = "CloudManV2"
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
  sign_in_policy {
    allowed_first_auth_factors      = ["PASSWORD"]
  }
  tags                              = {
    "Name" = "CloudManV2"
    "State" = "Auth"
    "CloudmanUser" = "GlobalUserName"
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

resource "aws_cognito_user_pool_client" "CloudManV2" {
  name                              = "CloudManV2"
  user_pool_id                      = aws_cognito_user_pool.CloudManV2.id
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
  token_validity_units {
    access_token                    = "hours"
    id_token                        = "hours"
    refresh_token                   = "hours"
  }
}

resource "aws_cognito_user_pool_domain" "CloudManV2" {
  user_pool_id                      = aws_cognito_user_pool.CloudManV2.id
  certificate_arn                   = data.aws_acm_certificate.Certificate.arn
  domain                            = "cog-auth.cloudman.pro"
}


