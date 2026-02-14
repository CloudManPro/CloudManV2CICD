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

data "aws_cloudfront_cache_policy" "policy_cachingoptimized" {
  name                              = "Managed-CachingOptimized"
}




### EXTERNAL REFERENCES ###

data "aws_acm_certificate" "Certificate" {
  domain                            = "auth.v2.cloudman.pro"
  most_recent                       = true
  statuses                          = ["ISSUED"]
}




### CATEGORY: NETWORK ###

resource "aws_route53_record" "alias_a_auth_to_Cog1" {
  name                              = "auth.v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "A"
  alias {
    name                            = aws_cognito_user_pool_domain.Cog1.cloudfront_distribution
    zone_id                         = aws_cognito_user_pool_domain.Cog1.cloudfront_distribution_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa_auth_to_Cog1" {
  name                              = "auth.v2.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Cloudman.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cognito_user_pool_domain.Cog1.cloudfront_distribution
    zone_id                         = aws_cognito_user_pool_domain.Cog1.cloudfront_distribution_zone_id
    evaluate_target_health          = false
  }
}




### CATEGORY: MISC ###

resource "aws_cognito_user_pool" "Cog1" {
  name                              = "Cog1"
  auto_verified_attributes          = ["email"]
  deletion_protection               = "ACTIVE"
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
    "Name" = "Cog1"
    "State" = "Auth"
    "CloudmanUser" = "GlobalUserName"
  }
  verification_message_template {
    default_email_option            = "CONFIRM_WITH_CODE"
  }
}

resource "aws_cognito_user_pool_client" "Cog1" {
  name                              = "Cog1"
  user_pool_id                      = aws_cognito_user_pool.Cog1.id
  access_token_validity             = 12
  allowed_oauth_flows               = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes              = ["openid", "email", "profile"]
  auth_session_validity             = 3
  callback_urls                     = ["https://v2.cloudman.pro"]
  enable_propagate_additional_user_context_data = false
  enable_token_revocation           = true
  explicit_auth_flows               = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH"]
  generate_secret                   = true
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

resource "aws_cognito_user_pool_domain" "Cog1" {
  user_pool_id                      = aws_cognito_user_pool.Cog1.id
  certificate_arn                   = data.aws_acm_certificate.Certificate.arn
  domain                            = "auth.v2.cloudman.pro"
}

resource "aws_ssm_parameter" "Parameter1" {
  name                              = "Parameter1"
  data_type                         = "text"
  description                       = "Auto-generated grouped map for: aws_cognito_user_pool.Cog1, aws_cognito_user_pool_client.Cog1, aws_cognito_user_pool_domain.Cog1"
  overwrite                         = false
  tier                              = "Standard"
  type                              = "String"
  value                             = jsonencode({
    "aws_cognito_user_pool" = {
      "Cog1" = {
        "arn" = "${aws_cognito_user_pool.Cog1.arn}"
        "creation_date" = "${aws_cognito_user_pool.Cog1.creation_date}"
        "custom_domain" = "${aws_cognito_user_pool.Cog1.custom_domain}"
        "domain" = "${aws_cognito_user_pool.Cog1.domain}"
        "endpoint" = "${aws_cognito_user_pool.Cog1.endpoint}"
        "estimated_number_of_users" = "${aws_cognito_user_pool.Cog1.estimated_number_of_users}"
        "last_modified_date" = "${aws_cognito_user_pool.Cog1.last_modified_date}"
      }
    }
    "aws_cognito_user_pool_client" = {
      "Cog1" = {
        "client_secret" = "${aws_cognito_user_pool_client.Cog1.client_secret}"
        "id" = "${aws_cognito_user_pool_client.Cog1.id}"
      }
    }
    "aws_cognito_user_pool_domain" = {
      "Cog1" = {
        "aws_account_id" = "${aws_cognito_user_pool_domain.Cog1.aws_account_id}"
        "cloudfront_distribution" = "${aws_cognito_user_pool_domain.Cog1.cloudfront_distribution}"
        "cloudfront_distribution_arn" = "${aws_cognito_user_pool_domain.Cog1.cloudfront_distribution_arn}"
        "cloudfront_distribution_zone_id" = "${aws_cognito_user_pool_domain.Cog1.cloudfront_distribution_zone_id}"
        "s3_bucket" = "${aws_cognito_user_pool_domain.Cog1.s3_bucket}"
        "version" = "${aws_cognito_user_pool_domain.Cog1.version}"
      }
    }
  })
  tags                              = {
    "Name" = "Parameter1"
    "State" = "Auth"
    "CloudmanUser" = "GlobalUserName"
  }
}


