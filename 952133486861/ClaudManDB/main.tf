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
    key            = "952133486861/ClaudManDB/main.tfstate"
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

### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "s3-cloudmanv2-files" {
  bucket                            = "s3-cloudmanv2-files"
  force_destroy                     = false
  object_lock_enabled               = false
  tags                              = {
    "Name" = "s3-cloudmanv2-files"
    "State" = "ClaudManDB"
    "CloudmanUser" = "GlobalUserName"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3-cloudmanv2-files_controls" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-files.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-cloudmanv2-files_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.s3-cloudmanv2-files.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-cloudmanv2-files_configuration" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-files.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
  }
}

resource "aws_s3_bucket_versioning" "s3-cloudmanv2-files_versioning" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-files.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_dynamodb_table" "CloudManV2" {
  name                              = "CloudManV2"
  billing_mode                      = "PROVISIONED"
  deletion_protection_enabled       = false
  hash_key                          = "ID"
  read_capacity                     = 1
  stream_enabled                    = false
  table_class                       = "STANDARD"
  write_capacity                    = 1
  tags                              = {
    "Name" = "CloudManV2"
    "State" = "ClaudManDB"
    "CloudmanUser" = "GlobalUserName"
  }
}


