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
    key            = "952133486861/State/main.tfstate"
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

### EXTERNAL REFERENCES ###

data "aws_cognito_user_pools" "Cog1" {
  name                              = "Cog1"
}




### CATEGORY: MISC ###

resource "aws_cognito_user_pool_client" "Cog" {
  name                              = "Cog"
  user_pool_id                      = data.aws_cognito_user_pools.Cog1.ids[0]
  access_token_validity             = 60
  allowed_oauth_flows_user_pool_client = false
  auth_session_validity             = 3
  enable_propagate_additional_user_context_data = false
  enable_token_revocation           = true
  explicit_auth_flows               = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  generate_secret                   = true
  id_token_validity                 = 60
  prevent_user_existence_errors     = "ENABLED"
  refresh_token_validity            = 30
  supported_identity_providers      = ["COGNITO"]
  token_validity_units {
    access_token                    = "minutes"
    id_token                        = "minutes"
    refresh_token                   = "days"
  }
}


