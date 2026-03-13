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
    key            = "952133486861/State3/main.tfstate"
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

### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC" {
  cidr_block                        = "10.0.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "VPC"
    "State" = "State3"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "Subnet" {
  vpc_id                            = aws_vpc.VPC.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.0.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet"
    "State" = "State3"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "Subnet1" {
  vpc_id                            = aws_vpc.VPC.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.1.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "Subnet1"
    "State" = "State3"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_security_group" "efs_file_system_EFS2_group" {
  name                              = "efs_file_system_EFS2_group"
  vpc_id                            = aws_vpc.VPC.id
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "efs_file_system_EFS2_group"
    "State" = "State3"
    "CloudmanUser" = "Ricardo"
  }
}




### CATEGORY: STORAGE ###

resource "aws_efs_file_system" "EFS2" {
  encrypted                         = true
  throughput_mode                   = "elastic"
  lifecycle_policy {
    transition_to_ia                = "AFTER_30_DAYS"
  }
  lifecycle_policy {
    transition_to_archive           = "AFTER_270_DAYS"
  }
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
  protection {
    replication_overwrite           = "ENABLED"
  }
  tags                              = {
    "Name" = "EFS2"
    "State" = "State3"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_efs_mount_target" "mt_EFS2_Subnet" {
  file_system_id                    = aws_efs_file_system.EFS2.id
  subnet_id                         = aws_subnet.Subnet.id
  security_groups                   = [aws_security_group.efs_file_system_EFS2_group.id]
}

resource "aws_efs_mount_target" "mt_EFS2_Subnet1" {
  file_system_id                    = aws_efs_file_system.EFS2.id
  subnet_id                         = aws_subnet.Subnet1.id
  security_groups                   = [aws_security_group.efs_file_system_EFS2_group.id]
}


