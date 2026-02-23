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
    key            = "952133486861/Pipe/dev/ClaudManDB-dev/main.tfstate"
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

resource "aws_s3_bucket" "s3-cloudmanv2-files-dev" {
  bucket                            = "s3-cloudmanv2-files-dev"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "s3-cloudmanv2-files-dev"
    "State" = "ClaudManDB-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3-cloudmanv2-files-dev_controls" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-files-dev.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-cloudmanv2-files-dev_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.s3-cloudmanv2-files-dev.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-cloudmanv2-files-dev_configuration" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-files-dev.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
    apply_server_side_encryption_by_default {
      sse_algorithm                 = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "s3-cloudmanv2-files-dev_versioning" {
  bucket                            = aws_s3_bucket.s3-cloudmanv2-files-dev.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_dynamodb_table" "CloudManV2-dev" {
  name                              = "CloudManV2-dev"
  billing_mode                      = "PROVISIONED"
  deletion_protection_enabled       = false
  hash_key                          = "Partition"
  range_key                         = "Sort"
  read_capacity                     = 1
  stream_enabled                    = false
  table_class                       = "STANDARD"
  write_capacity                    = 1
  attribute {
    name                            = "Partition"
    type                            = "S"
  }
  attribute {
    name                            = "Sort"
    type                            = "S"
  }
  tags                              = {
    "Name" = "CloudManV2-dev"
    "State" = "ClaudManDB-dev"
    "CloudmanUser" = "CloudMan2"
    "Stage" = "dev"
  }
}


