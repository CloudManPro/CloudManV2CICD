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

### SYSTEM DATA SOURCES ###

data "aws_route53_zone" "CloudMan" {
  name                              = "cloudman.pro"
}

data "aws_cloudfront_cache_policy" "policy_cachingoptimized" {
  name                              = "Managed-CachingOptimized"
}

data "aws_cloudfront_response_headers_policy" "policy_simplecors" {
  name                              = "Managed-SimpleCORS"
}




### EXTERNAL REFERENCES ###

data "aws_acm_certificate" "CertificateWP" {
  domain                            = "wp.cloudman.pro"
  most_recent                       = true
  statuses                          = ["ISSUED"]
}




### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "profile_Instance" {
  name                              = "profile_Instance"
  role                              = aws_iam_role.role_ec2_Instance.name
  tags                              = {
    "Name" = "profile_Instance"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

data "aws_iam_policy_document" "instance_Instance_st_Stateful_doc" {
  statement {
    sid                             = "AllowRDSSecretAccessDatabase1"
    effect                          = "Allow"
    actions                         = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources                       = ["${aws_db_instance.Database1.master_user_secret[0].secret_arn}"]
  }
  statement {
    sid                             = "AllowBucketLevelActions"
    effect                          = "Allow"
    actions                         = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources                       = ["${aws_s3_bucket.s3-off-load-wp-abcd.arn}"]
  }
  statement {
    sid                             = "AllowObjectCRUD"
    effect                          = "Allow"
    actions                         = ["s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
    resources                       = ["${aws_s3_bucket.s3-off-load-wp-abcd.arn}/*"]
  }
  statement {
    sid                             = "AllowBucketLevelActions1"
    effect                          = "Allow"
    actions                         = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources                       = ["${aws_s3_bucket.wp-script-cloudman.arn}"]
  }
  statement {
    sid                             = "AllowObjectCRUD1"
    effect                          = "Allow"
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.wp-script-cloudman.arn}/*"]
  }
  statement {
    sid                             = "EC2AndConsoleAccess"
    effect                          = "Allow"
    actions                         = ["ec2-instance-connect:SendSSHPublicKey", "ec2:DescribeInstances", "ec2:GetConsoleOutput", "ec2:GetConsoleScreenshot", "ec2:SendSerialConsoleSSHPublicKey", "ssm:UpdateInstanceInformation", "ssmmessages:CreateControlChannel", "ssmmessages:CreateDataChannel", "ssmmessages:OpenControlChannel", "ssmmessages:OpenDataChannel"]
    resources                       = ["*"]
  }
}

resource "aws_iam_policy" "instance_Instance_st_Stateful" {
  name                              = "instance_Instance_st_Stateful"
  description                       = "Access Policy for Instance"
  policy                            = data.aws_iam_policy_document.instance_Instance_st_Stateful_doc.json
}

resource "aws_iam_role" "role_ec2_Instance" {
  name                              = "role_ec2_Instance"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
})
  tags                              = {
    "Name" = "role_ec2_Instance"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_iam_role_policy_attachment" "instance_Instance_st_Stateful_attach" {
  policy_arn                        = aws_iam_policy.instance_Instance_st_Stateful.arn
  role                              = aws_iam_role.role_ec2_Instance.name
}




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

resource "aws_subnet" "WP" {
  vpc_id                            = aws_vpc.WordPress.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.1.4.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "WP"
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

resource "aws_route" "aws_route_RT_IGW" {
  gateway_id                        = aws_internet_gateway.IGW.id
  route_table_id                    = aws_route_table.RT.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route53_record" "alias_a_aws_cloudfront_distribution_CDN1" {
  name                              = "wp.cloudman.pro"
  zone_id                           = data.aws_route53_zone.CloudMan.zone_id
  type                              = "A"
  alias {
    name                            = aws_cloudfront_distribution.CDN1.domain_name
    zone_id                         = aws_cloudfront_distribution.CDN1.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_aaaa_aws_cloudfront_distribution_CDN1" {
  name                              = "wp.cloudman.pro"
  zone_id                           = data.aws_route53_zone.CloudMan.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cloudfront_distribution.CDN1.domain_name
    zone_id                         = aws_cloudfront_distribution.CDN1.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route_table" "RT" {
  vpc_id                            = aws_vpc.WordPress.id
  tags                              = {
    "Name" = "RT"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_route_table_association" "aws_route_table_association_WP_RT" {
  route_table_id                    = aws_route_table.RT.id
  subnet_id                         = aws_subnet.WP.id
}

resource "aws_security_group" "db_instance_Database1_group" {
  name                              = "db_instance_Database1_group"
  vpc_id                            = aws_vpc.WordPress.id
  description                       = "SG RDS"
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "db_instance_Database1_group"
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

resource "aws_security_group" "instance_Instance_group" {
  name                              = "instance_Instance_group"
  vpc_id                            = aws_vpc.WordPress.id
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "instance_Instance_group"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_security_group_rule" "rule_instance_Instance_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.instance_Instance_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_instance_Instance_group_ingress_tcp_80_80" {
  security_group_id                 = aws_security_group.instance_Instance_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 80
  protocol                          = "tcp"
  to_port                           = 80
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_Instance_group_to_db_instance_Database1_group_tcp_3306_3306" {
  security_group_id                 = aws_security_group.db_instance_Database1_group.id
  source_security_group_id          = aws_security_group.instance_Instance_group.id
  description                       = "Allow from instance_Instance_group (tcp:3306-3306)"
  from_port                         = 3306
  protocol                          = "tcp"
  to_port                           = 3306
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_Instance_group_to_efs_file_system_EFS_group_tcp_2049_2049" {
  security_group_id                 = aws_security_group.efs_file_system_EFS_group.id
  source_security_group_id          = aws_security_group.instance_Instance_group.id
  description                       = "Allow from instance_Instance_group (tcp:2049-2049)"
  from_port                         = 2049
  protocol                          = "tcp"
  to_port                           = 2049
  type                              = "ingress"
}

resource "aws_cloudfront_distribution" "CDN1" {
  aliases                           = ["wp.cloudman.pro"]
  default_root_object               = "index.html"
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    response_headers_policy_id      = data.aws_cloudfront_response_headers_policy.policy_simplecors.id
    target_origin_id                = "origin_WordPress"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    compress                        = true
    default_ttl                     = 0
    max_ttl                         = 0
    min_ttl                         = 0
    viewer_protocol_policy          = "allow-all"
    forwarded_values {
      headers                       = ["Host", "Origin", "X-Forwarded-Proto", "X-Forwarded-For", "X-Forwarded-Host"]
      query_string                  = true
      cookies {
        forward                     = "all"
      }
    }
  }
  ordered_cache_behavior {
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    target_origin_id                = "origin_StaticContentOffLoad"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    path_pattern                    = "/wp-content/uploads/*"
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = aws_s3_bucket.s3-off-load-wp-abcd.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_s3-off-load-wp-abcd.id
    origin_id                       = "origin_StaticContentOffLoad"
  }
  origin {
    domain_name                     = aws_instance.Instance.public_dns
    origin_id                       = "origin_WordPress"
    custom_origin_config {
      http_port                     = 80
      https_port                    = 443
      origin_protocol_policy        = "http-only"
      origin_ssl_protocols          = ["TLSv1.2"]
    }
  }
  restrictions {
    geo_restriction {
      restriction_type              = "none"
    }
  }
  tags                              = {
    "Name" = "CDN1"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
  viewer_certificate {
    acm_certificate_arn             = data.aws_acm_certificate.CertificateWP.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "oac_s3-off-load-wp-abcd" {
  name                              = "oac-s3-off-load-wp-abcd"
  description                       = "OAC for s3-off-load-wp-abcd"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
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

resource "aws_s3_bucket" "wp-script-cloudman" {
  bucket                            = "wp-script-cloudman"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "wp-script-cloudman"
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

resource "aws_s3_bucket_ownership_controls" "wp-script-cloudman_controls" {
  bucket                            = aws_s3_bucket.wp-script-cloudman.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_s3-off-load-wp-abcd_st_Stateful_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.s3-off-load-wp-abcd.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.CDN1.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_s3-off-load-wp-abcd_st_Stateful" {
  bucket                            = aws_s3_bucket.s3-off-load-wp-abcd.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_s3-off-load-wp-abcd_st_Stateful_doc.json
}

resource "aws_s3_bucket_public_access_block" "s3-off-load-wp-abcd_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.s3-off-load-wp-abcd.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_public_access_block" "wp-script-cloudman_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.wp-script-cloudman.id
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

resource "aws_s3_bucket_server_side_encryption_configuration" "wp-script-cloudman_configuration" {
  bucket                            = aws_s3_bucket.wp-script-cloudman.id
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

resource "aws_s3_bucket_versioning" "wp-script-cloudman_versioning" {
  bucket                            = aws_s3_bucket.wp-script-cloudman.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_db_instance" "Database1" {
  db_name                           = "wordpress"
  db_subnet_group_name              = aws_db_subnet_group.subnet_group_Database1.name
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
  vpc_security_group_ids            = [aws_security_group.db_instance_Database1_group.id]
  tags                              = {
    "Name" = "Database1"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_db_subnet_group" "subnet_group_Database1" {
  name                              = "database1-subnet-group"
  subnet_ids                        = [aws_subnet.DB_a.id, aws_subnet.DB_b.id]
  tags                              = {
    "Name" = "subnet_group_Database1"
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




### CATEGORY: COMPUTE ###

data "local_file" "UserData_Instance" {
  filename                          = "${path.module}/.external_modules/STRUCT8_Templates/EC2/Scripts/WordPress/FetchAndRunS3Script.sh"
}

data "aws_ami" "AMI_Data_Source_Instance" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "Instance" {
  subnet_id                         = aws_subnet.WP.id
  ami                               = data.aws_ami.AMI_Data_Source_Instance.id
  associate_public_ip_address       = true
  iam_instance_profile              = aws_iam_instance_profile.profile_Instance.name
  instance_type                     = "t3.micro"
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
AWS_S3_SCRIPT_KEY="WordPressProfessional.sh"
WPDOMAIN="wp.cloudman.pro"
NAME="Instance"
REGION="${data.aws_region.current.name}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
AWS_DB_INSTANCE_ENDPOINT_DB="${aws_db_instance.Database1.endpoint}"
AWS_DB_INSTANCE_DB_NAME_DB="${aws_db_instance.Database1.db_name}"
AWS_DB_INSTANCE_SECRET_ARN_DB="${one(aws_db_instance.Database1.master_user_secret[*].secret_arn)}"
AWS_EFS_ACCESS_POINT_ID_0="${aws_efs_access_point.AP.id}"
AWS_S3_BUCKET_NAME_OFF_LOAD="s3-off-load-wp-abcd"
AWS_S3_BUCKET_NAME_SCRIPT="wp-script-cloudman"
AWS_EFS_FILE_SYSTEM_ID_0="${aws_efs_file_system.EFS.id}"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

${data.local_file.UserData_Instance.content}
EOFUData
)
  user_data_replace_on_change       = false
  vpc_security_group_ids            = [aws_security_group.instance_Instance_group.id]
  tags                              = {
    "Name" = "Instance"
    "State" = "Stateful"
    "CloudmanUser" = "Ricardo"
  }
  depends_on                        = [aws_iam_role_policy_attachment.instance_Instance_st_Stateful_attach]
}


