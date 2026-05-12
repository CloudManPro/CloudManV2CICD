terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
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

resource "aws_s3_bucket" "struct8-public-cloudformation-templates" {
  bucket                            = "struct8-public-cloudformation-templates"
  force_destroy                     = false
  object_lock_enabled               = false
  tags                              = {
    Name = "struct8-public-cloudformation-templates"
    State = "CloudformationTemplate"
    Struct8User = "Struc8"
  }
}

resource "aws_s3_bucket_ownership_controls" "struct8-public-cloudformation-templates_controls" {
  bucket                            = aws_s3_bucket.struct8-public-cloudformation-templates.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_struct8-public-cloudformation-templates_st_CloudformationTemplate_doc" {
  statement {
    sid                             = "PublicReadGetObject"
    effect                          = "Allow"
    principals {
      identifiers                   = ["*"]
      type                          = "AWS"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.struct8-public-cloudformation-templates.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_struct8-public-cloudformation-templates_st_CloudformationTemplate" {
  bucket                            = aws_s3_bucket.struct8-public-cloudformation-templates.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_struct8-public-cloudformation-templates_st_CloudformationTemplate_doc.json
}

resource "aws_s3_bucket_public_access_block" "struct8-public-cloudformation-templates_block" {
  block_public_acls                 = false
  block_public_policy               = false
  bucket                            = aws_s3_bucket.struct8-public-cloudformation-templates.id
  ignore_public_acls                = false
  restrict_public_buckets           = false
}

resource "aws_s3_bucket_server_side_encryption_configuration" "struct8-public-cloudformation-templates_configuration" {
  bucket                            = aws_s3_bucket.struct8-public-cloudformation-templates.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
  }
}

resource "aws_s3_bucket_versioning" "struct8-public-cloudformation-templates_versioning" {
  bucket                            = aws_s3_bucket.struct8-public-cloudformation-templates.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_s3_object" "CrossAccountStruct8" {
  source                            = "${path.module}/.external_modules/CloudMan/CloudFrontTemplate/CrossAccountStruct8.yaml"
  bucket                            = aws_s3_bucket.struct8-public-cloudformation-templates.bucket
  content_type                      = "text/yaml"
  etag                              = filemd5("${path.module}/.external_modules/CloudMan/CloudFrontTemplate/CrossAccountStruct8.yaml")
  key                               = "CrossAccountStruct8.yaml"
  tags                              = {
    Name = "CrossAccountStruct8"
    State = "CloudformationTemplate"
    Struct8User = "Struc8"
  }
}

resource "aws_s3_object" "TerraformBackend" {
  source                            = "${path.module}/.external_modules/CloudMan/CloudFrontTemplate/TerraformBackend.yml"
  bucket                            = aws_s3_bucket.struct8-public-cloudformation-templates.bucket
  content_type                      = "text/yaml"
  etag                              = filemd5("${path.module}/.external_modules/CloudMan/CloudFrontTemplate/TerraformBackend.yml")
  key                               = "TerraformBackend.yml"
  tags                              = {
    Name = "TerraformBackend"
    State = "CloudformationTemplate"
    Struct8User = "Struc8"
  }
}


