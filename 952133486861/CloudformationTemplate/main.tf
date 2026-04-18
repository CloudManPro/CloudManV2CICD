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
    key            = "952133486861/CloudformationTemplate/main.tfstate"
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

resource "aws_s3_bucket" "struct8-cloudformation-template" {
  bucket                            = "struct8-cloudformation-template"
  force_destroy                     = false
  object_lock_enabled               = false
  tags                              = {
    "Name" = "struct8-cloudformation-template"
    "State" = "CloudformationTemplate"
    "Struct8User" = "Struc8"
  }
}

resource "aws_s3_bucket_ownership_controls" "struct8-cloudformation-template_controls" {
  bucket                            = aws_s3_bucket.struct8-cloudformation-template.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "struct8-cloudformation-template_block" {
  block_public_acls                 = false
  block_public_policy               = false
  bucket                            = aws_s3_bucket.struct8-cloudformation-template.id
  ignore_public_acls                = false
  restrict_public_buckets           = false
}

resource "aws_s3_bucket_server_side_encryption_configuration" "struct8-cloudformation-template_configuration" {
  bucket                            = aws_s3_bucket.struct8-cloudformation-template.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
  }
}

resource "aws_s3_bucket_versioning" "struct8-cloudformation-template_versioning" {
  bucket                            = aws_s3_bucket.struct8-cloudformation-template.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_s3_object" "CrossAccountCloudMan" {
  source                            = "${path.module}/.external_modules/CloudMan/CloudFrontTemplate/CrossAccountCloudMan.yaml"
  bucket                            = aws_s3_bucket.struct8-cloudformation-template.bucket
  content_type                      = "text/yaml"
  etag                              = filemd5("${path.module}/.external_modules/CloudMan/CloudFrontTemplate/CrossAccountCloudMan.yaml")
  key                               = "CrossAccountCloudMan.yaml"
  tags                              = {
    "Name" = "CrossAccountCloudMan"
    "State" = "CloudformationTemplate"
    "Struct8User" = "Struc8"
  }
}

resource "aws_s3_object" "TerraformBackend" {
  source                            = "${path.module}/.external_modules/CloudMan/CloudFrontTemplate/TerraformBackend.yml"
  bucket                            = aws_s3_bucket.struct8-cloudformation-template.bucket
  content_type                      = "text/yaml"
  etag                              = filemd5("${path.module}/.external_modules/CloudMan/CloudFrontTemplate/TerraformBackend.yml")
  key                               = "TerraformBackend.yml"
  tags                              = {
    "Name" = "TerraformBackend"
    "State" = "CloudformationTemplate"
    "Struct8User" = "Struc8"
  }
}


