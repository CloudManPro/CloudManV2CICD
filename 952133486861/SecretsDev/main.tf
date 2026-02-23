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
    key            = "952133486861/SecretsDev/main.tfstate"
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

### CATEGORY: MISC ###

resource "aws_ssm_parameter" "GitHubAppKeyDev" {
  name                              = "GitHubAppKeyDev"
  data_type                         = "text"
  overwrite                         = false
  tier                              = "Standard"
  type                              = "SecureString"
  value                             = "a"
  tags                              = {
    "Name" = "GitHubAppKeyDev"
    "State" = "SecretsDev"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_ssm_parameter" "GithubClientAndSecret" {
  name                              = "GithubClientAndSecret"
  data_type                         = "text"
  overwrite                         = false
  tier                              = "Standard"
  type                              = "SecureString"
  value                             = "a"
  tags                              = {
    "Name" = "GithubClientAndSecret"
    "State" = "SecretsDev"
    "CloudmanUser" = "GlobalUserName"
  }
}


