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
    key            = "952133486861/Stateful/main.tfstate"
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

resource "aws_vpc" "WordPress" {
  cidr_block                        = "10.1.0.0/16"
  enable_dns_hostnames              = true
  enable_dns_support                = true
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "WordPress"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "DB_a" {
  vpc_id                            = aws_vpc.WordPress.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.1.0.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "DB_a"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "DB_b" {
  vpc_id                            = aws_vpc.WordPress.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.1.1.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "DB_b"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "EFS_a" {
  vpc_id                            = aws_vpc.WordPress.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.1.2.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "EFS_a"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "EFS_b" {
  vpc_id                            = aws_vpc.WordPress.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.1.3.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "EFS_b"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id                            = aws_vpc.WordPress.id
  tags                              = {
    "Name" = "IGW"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_security_group" "db_instance_database1_group" {
  name                              = "db_instance_database1_group"
  vpc_id                            = aws_vpc.WordPress.id
  description                       = "SG RDS"
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "db_instance_database1_group"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_security_group" "efs_file_system_EFS_group" {
  name                              = "efs_file_system_EFS_group"
  vpc_id                            = aws_vpc.WordPress.id
  description                       = "SG EFS"
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "efs_file_system_EFS_group"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "s3-off-load-wp-abcd" {
  bucket                            = "s3-off-load-wp-abcd"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "s3-off-load-wp-abcd"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3-off-load-wp-abcd_controls" {
  bucket                            = aws_s3_bucket.s3-off-load-wp-abcd.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-off-load-wp-abcd_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.s3-off-load-wp-abcd.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-off-load-wp-abcd_configuration" {
  bucket                            = aws_s3_bucket.s3-off-load-wp-abcd.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
  }
}

resource "aws_s3_bucket_versioning" "s3-off-load-wp-abcd_versioning" {
  bucket                            = aws_s3_bucket.s3-off-load-wp-abcd.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_db_instance" "database1" {
  db_name                           = "wordpress"
  db_subnet_group_name              = aws_db_subnet_group.subnet_group_database1.name
  allocated_storage                 = 20
  availability_zone                 = aws_subnet.DB_a.availability_zone
  backup_retention_period           = 0
  copy_tags_to_snapshot             = true
  delete_automated_backups          = false
  engine                            = "mysql"
  engine_version                    = "8.0"
  iam_database_authentication_enabled = true
  identifier                        = "database1"
  instance_class                    = "db.t3.micro"
  manage_master_user_password       = true
  max_allocated_storage             = 100
  skip_final_snapshot               = true
  storage_encrypted                 = true
  storage_type                      = "gp3"
  upgrade_storage_config            = false
  username                          = "admin"
  vpc_security_group_ids            = [aws_security_group.db_instance_database1_group.id]
  tags                              = {
    "Name" = "database1"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_db_subnet_group" "subnet_group_database1" {
  name                              = "database1-subnet-group"
  subnet_ids                        = [aws_subnet.DB_b.id, aws_subnet.DB_a.id]
  tags                              = {
    "Name" = "subnet_group_database1"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_efs_access_point" "AP" {
  file_system_id                    = aws_efs_file_system.EFS.id
  posix_user {
    gid                             = 48
    uid                             = 48
  }
  root_directory {
    path                            = "/wordpress"
    creation_info {
      owner_gid                     = 48
      owner_uid                     = 48
      permissions                   = "0755"
    }
  }
  tags                              = {
    "Name" = "AP"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_efs_file_system" "EFS" {
  encrypted                         = true
  throughput_mode                   = "elastic"
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
  protection {
    replication_overwrite           = "ENABLED"
  }
  tags                              = {
    "Name" = "EFS"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_efs_mount_target" "mt_EFS_EFS_a" {
  file_system_id                    = aws_efs_file_system.EFS.id
  subnet_id                         = aws_subnet.EFS_a.id
  security_groups                   = [aws_security_group.efs_file_system_EFS_group.id]
}

resource "aws_efs_mount_target" "mt_EFS_EFS_b" {
  file_system_id                    = aws_efs_file_system.EFS.id
  subnet_id                         = aws_subnet.EFS_b.id
  security_groups                   = [aws_security_group.efs_file_system_EFS_group.id]
}


