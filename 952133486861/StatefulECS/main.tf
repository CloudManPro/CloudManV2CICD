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
    key            = "952133486861/StatefulECS/main.tfstate"
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

resource "aws_iam_instance_profile" "profile_NAT" {
  name                              = "profile_NAT"
  role                              = aws_iam_role.role_ec2_NAT.name
  tags                              = {
    "Name" = "profile_NAT"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

data "aws_iam_policy_document" "ecs_task_definition_WordPress_execution_st_StatefulECS_doc" {
  statement {
    sid                             = "AllowWriteLogs"
    effect                          = "Allow"
    actions                         = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources                       = ["${aws_cloudwatch_log_group.WordPress.arn}:*"]
  }
}

resource "aws_iam_policy" "ecs_task_definition_WordPress_execution_st_StatefulECS" {
  name                              = "ecs_task_definition_WordPress_execution_st_StatefulECS"
  description                       = "Access Policy for WordPress (Role: execution)"
  policy                            = data.aws_iam_policy_document.ecs_task_definition_WordPress_execution_st_StatefulECS_doc.json
}

data "aws_iam_policy_document" "ecs_task_definition_WordPress_task_st_StatefulECS_doc" {
  statement {
    sid                             = "AllowRDSSecretAccessDatabase4"
    effect                          = "Allow"
    actions                         = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources                       = ["${aws_db_instance.Database4.master_user_secret[0].secret_arn}"]
  }
  statement {
    sid                             = "AllowEFSAccess"
    effect                          = "Allow"
    actions                         = ["elasticfilesystem:ClientMount", "elasticfilesystem:ClientRootAccess", "elasticfilesystem:ClientWrite"]
    resources                       = ["${aws_efs_file_system.EFS2.arn}:*"]
  }
  statement {
    sid                             = "AllowBucketLevelActions"
    effect                          = "Allow"
    actions                         = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources                       = ["${aws_s3_bucket.s3-off-load-wp-abcd1.arn}"]
  }
  statement {
    sid                             = "AllowObjectCRUD"
    effect                          = "Allow"
    actions                         = ["s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
    resources                       = ["${aws_s3_bucket.s3-off-load-wp-abcd1.arn}/*"]
  }
}

resource "aws_iam_policy" "ecs_task_definition_WordPress_task_st_StatefulECS" {
  name                              = "ecs_task_definition_WordPress_task_st_StatefulECS"
  description                       = "Access Policy for WordPress (Role: task)"
  policy                            = data.aws_iam_policy_document.ecs_task_definition_WordPress_task_st_StatefulECS_doc.json
}

resource "aws_iam_role" "execution_role_ecs_WordPress" {
  name                              = "execution_role_ecs_WordPress"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
})
  tags                              = {
    "Name" = "execution_role_ecs_WordPress"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_iam_role" "role_ec2_NAT" {
  name                              = "role_ec2_NAT"
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
    "Name" = "role_ec2_NAT"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_iam_role" "task_role_ecs_WordPress" {
  name                              = "task_role_ecs_WordPress"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
})
  tags                              = {
    "Name" = "task_role_ecs_WordPress"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_definition_WordPress_execution_st_StatefulECS_attach" {
  policy_arn                        = aws_iam_policy.ecs_task_definition_WordPress_execution_st_StatefulECS.arn
  role                              = aws_iam_role.execution_role_ecs_WordPress.name
}

resource "aws_iam_role_policy_attachment" "ecs_task_definition_WordPress_task_st_StatefulECS_attach" {
  policy_arn                        = aws_iam_policy.ecs_task_definition_WordPress_task_st_StatefulECS.arn
  role                              = aws_iam_role.task_role_ecs_WordPress.name
}

resource "aws_acm_certificate" "CertificateALB" {
  domain_name                       = "alb.wp.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  validation_method                 = "DNS"
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "Name" = "CertificateALB"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_acm_certificate_validation" "Validation_CertificateALB" {
  certificate_arn                   = aws_acm_certificate.CertificateALB.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_CertificateALB : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "WordPress3" {
  cidr_block                        = "10.0.0.0/16"
  enable_dns_hostnames              = true
  enable_dns_support                = true
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "WordPress3"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "DB_a1" {
  vpc_id                            = aws_vpc.WordPress3.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.0.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "DB_a1"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "DB_b1" {
  vpc_id                            = aws_vpc.WordPress3.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.2.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "DB_b1"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "EFS_a1" {
  vpc_id                            = aws_vpc.WordPress3.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.1.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "EFS_a1"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "EFS_b1" {
  vpc_id                            = aws_vpc.WordPress3.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.3.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "EFS_b1"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "Public-b" {
  vpc_id                            = aws_vpc.WordPress3.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.5.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Public-b"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "WP-a" {
  vpc_id                            = aws_vpc.WordPress3.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.6.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "WP-a"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "WP-b" {
  vpc_id                            = aws_vpc.WordPress3.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.7.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    "Name" = "WP-b"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id                            = aws_vpc.WordPress3.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.4.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "public-a"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_internet_gateway" "IGW3" {
  vpc_id                            = aws_vpc.WordPress3.id
  tags                              = {
    "Name" = "IGW3"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_route" "aws_route_RT5_IGW3" {
  gateway_id                        = aws_internet_gateway.IGW3.id
  route_table_id                    = aws_route_table.RT5.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route" "aws_route_RT_Private_to_Public_NAT" {
  network_interface_id              = aws_instance.NAT.primary_network_interface_id
  route_table_id                    = aws_route_table.RT-Private-to-Public.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route53_record" "Route53_Record_CertificateALB" {
  for_each                          = {for dvo in aws_acm_certificate.CertificateALB.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name,
      record = dvo.resource_record_value,
      type   = dvo.resource_record_type
    }}
  name                              = "${each.value.name}"
  zone_id                           = data.aws_route53_zone.CloudMan.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.record}"]
  ttl                               = 300
  type                              = "${each.value.type}"
}

resource "aws_route53_record" "alias_a_aws_cloudfront_distribution_CDN2" {
  name                              = "wp.cloudman.pro"
  zone_id                           = data.aws_route53_zone.CloudMan.zone_id
  type                              = "A"
  alias {
    name                            = aws_cloudfront_distribution.CDN2.domain_name
    zone_id                         = aws_cloudfront_distribution.CDN2.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route53_record" "alias_a_aws_lb_Xalb_ALB" {
  name                              = "alb.wp.cloudman.pro"
  zone_id                           = data.aws_route53_zone.CloudMan.zone_id
  type                              = "A"
  alias {
    name                            = aws_lb.ALB.dns_name
    zone_id                         = aws_lb.ALB.zone_id
    evaluate_target_health          = true
  }
}

resource "aws_route53_record" "alias_aaaa_aws_cloudfront_distribution_CDN2" {
  name                              = "wp.cloudman.pro"
  zone_id                           = data.aws_route53_zone.CloudMan.zone_id
  type                              = "AAAA"
  alias {
    name                            = aws_cloudfront_distribution.CDN2.domain_name
    zone_id                         = aws_cloudfront_distribution.CDN2.hosted_zone_id
    evaluate_target_health          = false
  }
}

resource "aws_route_table" "RT-Private-to-Public" {
  vpc_id                            = aws_vpc.WordPress3.id
  tags                              = {
    "Name" = "RT-Private-to-Public"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_route_table" "RT5" {
  vpc_id                            = aws_vpc.WordPress3.id
  tags                              = {
    "Name" = "RT5"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Public_b_RT5" {
  route_table_id                    = aws_route_table.RT5.id
  subnet_id                         = aws_subnet.Public-b.id
}

resource "aws_route_table_association" "aws_route_table_association_WP_a_RT_Private_to_Public" {
  route_table_id                    = aws_route_table.RT-Private-to-Public.id
  subnet_id                         = aws_subnet.WP-a.id
}

resource "aws_route_table_association" "aws_route_table_association_WP_b_RT_Private_to_Public" {
  route_table_id                    = aws_route_table.RT-Private-to-Public.id
  subnet_id                         = aws_subnet.WP-b.id
}

resource "aws_route_table_association" "aws_route_table_association_public_a_RT5" {
  route_table_id                    = aws_route_table.RT5.id
  subnet_id                         = aws_subnet.public-a.id
}

resource "aws_security_group" "SG_ECS_WP" {
  name                              = "SG_ECS_WP"
  vpc_id                            = aws_vpc.WordPress3.id
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "SG_ECS_WP"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_security_group" "db_instance_Database4_group" {
  name                              = "db_instance_Database4_group"
  vpc_id                            = aws_vpc.WordPress3.id
  description                       = "SG RDS"
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "db_instance_Database4_group"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_security_group" "efs_file_system_EFS2_group" {
  name                              = "efs_file_system_EFS2_group"
  vpc_id                            = aws_vpc.WordPress3.id
  description                       = "SG EFS"
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "efs_file_system_EFS2_group"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_security_group" "instance_NAT_group" {
  name                              = "instance_NAT_group"
  vpc_id                            = aws_vpc.WordPress3.id
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "instance_NAT_group"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_security_group" "lb_alb_ALB_group" {
  name                              = "lb_alb_ALB_group"
  vpc_id                            = aws_vpc.WordPress3.id
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "lb_alb_ALB_group"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_security_group_rule" "rule_SG_ECS_WP_egress_all_protocols" {
  security_group_id                 = aws_security_group.SG_ECS_WP.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_SG_ECS_WP_to_db_instance_Database4_group_tcp_3306" {
  security_group_id                 = aws_security_group.db_instance_Database4_group.id
  source_security_group_id          = aws_security_group.SG_ECS_WP.id
  description                       = "RDS Access"
  from_port                         = 3306
  protocol                          = "tcp"
  to_port                           = 3306
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_SG_ECS_WP_to_efs_file_system_EFS2_group_tcp_2049" {
  security_group_id                 = aws_security_group.efs_file_system_EFS2_group.id
  source_security_group_id          = aws_security_group.SG_ECS_WP.id
  description                       = "Allow from SG_ECS_WP (tcp:2049-2049)"
  from_port                         = 2049
  protocol                          = "tcp"
  to_port                           = 2049
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_SG_ECS_WP_to_instance_NAT_group_all_protocols" {
  security_group_id                 = aws_security_group.instance_NAT_group.id
  source_security_group_id          = aws_security_group.SG_ECS_WP.id
  description                       = "Permits from ECS"
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_NAT_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.instance_NAT_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_lb_alb_ALB_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.lb_alb_ALB_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_lb_alb_ALB_group_ingress_tcp_443" {
  security_group_id                 = aws_security_group.lb_alb_ALB_group.id
  from_port                         = 443
  protocol                          = "tcp"
  to_port                           = 443
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_lb_alb_ALB_group_to_SG_ECS_WP_tcp_80" {
  security_group_id                 = aws_security_group.SG_ECS_WP.id
  source_security_group_id          = aws_security_group.lb_alb_ALB_group.id
  description                       = "Allow from lb_alb_ALB_group (tcp:80-80)"
  from_port                         = 80
  protocol                          = "tcp"
  to_port                           = 80
  type                              = "ingress"
}

resource "aws_lb" "ALB" {
  name                              = "ALB"
  idle_timeout                      = 60
  load_balancer_type                = "application"
  security_groups                   = [aws_security_group.lb_alb_ALB_group.id]
  subnets                           = [aws_subnet.public-a.id, aws_subnet.Public-b.id]
  tags                              = {
    "Name" = "ALB"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_lb_listener" "Listener" {
  load_balancer_arn                 = aws_lb.ALB.arn
  port                              = 443
  protocol                          = "HTTPS"
  routing_http_response_server_enabled = true
  default_action {
    order                           = 1
    target_group_arn                = aws_lb_target_group.TG2.arn
    type                            = "forward"
    forward {
      target_group {
        arn                         = aws_lb_target_group.TG2.arn
      }
    }
  }
  tags                              = {
    "Name" = "Listener"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_lb_target_group" "TG2" {
  name                              = "TG2"
  vpc_id                            = aws_vpc.WordPress3.id
  connection_termination            = false
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  port                              = 80
  protocol                          = "HTTP"
  protocol_version                  = "HTTP1"
  proxy_protocol_v2                 = false
  slow_start                        = 0
  target_type                       = "ip"
  health_check {
    enabled                         = true
    healthy_threshold               = 3
    interval                        = 30
    matcher                         = "200-399"
    path                            = "/"
    port                            = 80
    protocol                        = "HTTP"
    timeout                         = 5
    unhealthy_threshold             = 3
  }
  tags                              = {
    "Name" = "TG2"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_cloudfront_distribution" "CDN2" {
  aliases                           = ["wp.cloudman.pro"]
  enabled                           = true
  http_version                      = "http2and3"
  is_ipv6_enabled                   = true
  price_class                       = "PriceClass_All"
  default_cache_behavior {
    response_headers_policy_id      = data.aws_cloudfront_response_headers_policy.policy_simplecors.id
    target_origin_id                = "origin_WordPress1"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    compress                        = true
    default_ttl                     = 0
    max_ttl                         = 0
    min_ttl                         = 0
    viewer_protocol_policy          = "redirect-to-https"
    forwarded_values {
      headers                       = ["Host", "Origin", "X-Forwarded-Proto", "X-Forwarded-For", "X-Forwarded-Host", "CloudFront-Forwarded-Proto"]
      query_string                  = true
      cookies {
        forward                     = "all"
      }
    }
  }
  ordered_cache_behavior {
    cache_policy_id                 = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    target_origin_id                = "origin_StaticContentOffLoad1"
    allowed_methods                 = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods                  = ["GET", "HEAD", "OPTIONS"]
    path_pattern                    = "/wp-content/uploads/*"
    viewer_protocol_policy          = "redirect-to-https"
  }
  origin {
    domain_name                     = aws_s3_bucket.s3-off-load-wp-abcd1.bucket_regional_domain_name
    origin_access_control_id        = aws_cloudfront_origin_access_control.oac_s3-off-load-wp-abcd1.id
    origin_id                       = "origin_StaticContentOffLoad1"
  }
  origin {
    domain_name                     = aws_lb.ALB.dns_name
    origin_id                       = "origin_WordPress1"
    custom_origin_config {
      http_port                     = 80
      https_port                    = 443
      origin_protocol_policy        = "https-only"
      origin_ssl_protocols          = ["TLSv1.2"]
    }
  }
  restrictions {
    geo_restriction {
      restriction_type              = "none"
    }
  }
  tags                              = {
    "Name" = "CDN2"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
  viewer_certificate {
    acm_certificate_arn             = data.aws_acm_certificate.CertificateWP.arn
    cloudfront_default_certificate  = false
    minimum_protocol_version        = "TLSv1.2_2021"
    ssl_support_method              = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "oac_s3-off-load-wp-abcd1" {
  name                              = "oac-s3-off-load-wp-abcd1"
  description                       = "OAC for s3-off-load-wp-abcd1"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "s3-off-load-wp-abcd1" {
  bucket                            = "s3-off-load-wp-abcd1"
  force_destroy                     = true
  object_lock_enabled               = false
  tags                              = {
    "Name" = "s3-off-load-wp-abcd1"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3-off-load-wp-abcd1_controls" {
  bucket                            = aws_s3_bucket.s3-off-load-wp-abcd1.id
  rule {
    object_ownership                = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_s3-off-load-wp-abcd1_st_StatefulECS_doc" {
  statement {
    sid                             = "AllowCloudFrontServicePrincipalReadOnly"
    effect                          = "Allow"
    principals {
      identifiers                   = ["cloudfront.amazonaws.com"]
      type                          = "Service"
    }
    actions                         = ["s3:GetObject"]
    resources                       = ["${aws_s3_bucket.s3-off-load-wp-abcd1.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.CDN2.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_s3-off-load-wp-abcd1_st_StatefulECS" {
  bucket                            = aws_s3_bucket.s3-off-load-wp-abcd1.id
  policy                            = data.aws_iam_policy_document.aws_s3_bucket_policy_s3-off-load-wp-abcd1_st_StatefulECS_doc.json
}

resource "aws_s3_bucket_public_access_block" "s3-off-load-wp-abcd1_block" {
  block_public_acls                 = true
  block_public_policy               = true
  bucket                            = aws_s3_bucket.s3-off-load-wp-abcd1.id
  ignore_public_acls                = true
  restrict_public_buckets           = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-off-load-wp-abcd1_configuration" {
  bucket                            = aws_s3_bucket.s3-off-load-wp-abcd1.id
  expected_bucket_owner             = data.aws_caller_identity.current.account_id
  rule {
    bucket_key_enabled              = true
  }
}

resource "aws_s3_bucket_versioning" "s3-off-load-wp-abcd1_versioning" {
  bucket                            = aws_s3_bucket.s3-off-load-wp-abcd1.id
  versioning_configuration {
    mfa_delete                      = "Disabled"
    status                          = "Suspended"
  }
}

resource "aws_db_instance" "Database4" {
  db_name                           = "wordpress"
  db_subnet_group_name              = aws_db_subnet_group.subnet_group_Database4.name
  allocated_storage                 = 20
  availability_zone                 = aws_subnet.DB_a1.availability_zone
  backup_retention_period           = 0
  copy_tags_to_snapshot             = true
  delete_automated_backups          = false
  engine                            = "mysql"
  engine_version                    = "8.0"
  iam_database_authentication_enabled = true
  identifier                        = "Database4"
  instance_class                    = "db.t3.micro"
  manage_master_user_password       = true
  max_allocated_storage             = 100
  skip_final_snapshot               = true
  storage_encrypted                 = true
  storage_type                      = "gp3"
  upgrade_storage_config            = false
  username                          = "admin"
  vpc_security_group_ids            = [aws_security_group.db_instance_Database4_group.id]
  tags                              = {
    "Name" = "Database4"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_db_subnet_group" "subnet_group_Database4" {
  name                              = "database4-subnet-group"
  subnet_ids                        = [aws_subnet.DB_b1.id, aws_subnet.DB_a1.id]
  tags                              = {
    "Name" = "subnet_group_Database4"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_efs_access_point" "AP2" {
  file_system_id                    = aws_efs_file_system.EFS2.id
  posix_user {
    gid                             = 33
    uid                             = 33
  }
  root_directory {
    path                            = "/wordpress"
    creation_info {
      owner_gid                     = 33
      owner_uid                     = 33
      permissions                   = "0755"
    }
  }
  tags                              = {
    "Name" = "AP2"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_efs_file_system" "EFS2" {
  encrypted                         = true
  throughput_mode                   = "elastic"
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
  protection {
    replication_overwrite           = "ENABLED"
  }
  tags                              = {
    "Name" = "EFS2"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_efs_mount_target" "mt_EFS2_EFS_a1" {
  file_system_id                    = aws_efs_file_system.EFS2.id
  subnet_id                         = aws_subnet.EFS_a1.id
  security_groups                   = [aws_security_group.efs_file_system_EFS2_group.id]
}

resource "aws_efs_mount_target" "mt_EFS2_EFS_b1" {
  file_system_id                    = aws_efs_file_system.EFS2.id
  subnet_id                         = aws_subnet.EFS_b1.id
  security_groups                   = [aws_security_group.efs_file_system_EFS2_group.id]
}




### CATEGORY: COMPUTE ###

data "local_file" "UserData_NAT" {
  filename                          = "${path.module}/.external_modules/CloudMan/EC2/NATGateway/NAT.sh"
}

data "aws_ami" "AMI_Data_Source_NAT" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "NAT" {
  subnet_id                         = aws_subnet.Public-b.id
  ami                               = data.aws_ami.AMI_Data_Source_NAT.id
  associate_public_ip_address       = true
  iam_instance_profile              = aws_iam_instance_profile.profile_NAT.name
  instance_type                     = "t3.nano"
  source_dest_check                 = false
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash

${data.local_file.UserData_NAT.content}
EOFUData
)
  user_data_replace_on_change       = true
  vpc_security_group_ids            = [aws_security_group.instance_NAT_group.id]
  instance_market_options {
    market_type                     = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
      spot_instance_type            = "one-time"
    }
  }
  tags                              = {
    "Name" = "NAT"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_ecs_cluster" "ECSCluster2" {
  name                              = "ECSCluster2"
  tags                              = {
    "Name" = "ECSCluster2"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_ecs_service" "WordPress_service" {
  name                              = "WordPress_service"
  cluster                           = aws_ecs_cluster.ECSCluster2.id
  desired_count                     = 1
  enable_ecs_managed_tags           = true
  force_delete                      = true
  launch_type                       = "FARGATE"
  propagate_tags                    = "TASK_DEFINITION"
  scheduling_strategy               = "REPLICA"
  task_definition                   = aws_ecs_task_definition.WordPress.arn
  deployment_controller {
    type                            = "ECS"
  }
  load_balancer {
    container_name                  = "Container1"
    container_port                  = 80
    target_group_arn                = aws_lb_target_group.TG2.arn
  }
  network_configuration {
    assign_public_ip                = false
    security_groups                 = [aws_security_group.SG_ECS_WP.id]
    subnets                         = [aws_subnet.WP-a.id, aws_subnet.WP-b.id]
  }
  tags                              = {
    "Name" = "WordPress_service"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}

locals {
  container_def_WordPress_Container1 = {
    "name" = "Container1"
    "image" = "wordpress:6.8-php8.2-apache"
    "essential" = true
    "cpu" = 1024
    "memory" = 2000
    "portMappings" = [{
    "protocol" = "tcp"
    "containerPort" = 80
    "hostPort" = 80
  }]
    "environment" = [{
    "name" = "NAME"
    "value" = "Container1"
  }, {
    "name" = "REGION"
    "value" = "${data.aws_region.current.name}"
  }, {
    "name" = "ACCOUNT"
    "value" = "${data.aws_caller_identity.current.account_id}"
  }, {
    "name" = "AWS_DB_INSTANCE_ENDPOINT_DB"
    "value" = "${aws_db_instance.Database4.endpoint}"
  }, {
    "name" = "AWS_DB_INSTANCE_DB_NAME_DB"
    "value" = "${aws_db_instance.Database4.db_name}"
  }, {
    "name" = "AWS_DB_INSTANCE_USER_NAME_DB"
    "value" = "${aws_db_instance.Database4.username}"
  }, {
    "name" = "AWS_EFS_FILE_SYSTEM_ID_0"
    "value" = "${aws_efs_file_system.EFS2.id}"
  }, {
    "name" = "AWS_INSTANCE_NAME_0"
    "value" = "NAT"
  }, {
    "name" = "AWS_S3_BUCKET_NAME_0"
    "value" = "s3-off-load-wp-abcd1"
  }]
    "secrets" = [{
    "name" = "AWS_DB_INSTANCE_PASS_DB"
    "valueFrom" = "${one(aws_db_instance.Database4.master_user_secret[*].secret_arn)}:password::"
  }]
    "mountPoints" = [{
    "sourceVolume" = "aws_efs_access_point_AP2"
    "containerPath" = "/var/www/html"
    "readOnly" = false
  }]
    "entryPoint" = ["sh", "-c", <<-EOT
        export WORDPRESS_DB_HOST=$AWS_DB_INSTANCE_ENDPOINT_DB
        export WORDPRESS_DB_NAME=$AWS_DB_INSTANCE_DB_NAME_DB
        export WORDPRESS_DB_USER=$AWS_DB_INSTANCE_USER_NAME_DB
        export WORDPRESS_DB_PASSWORD=$AWS_DB_INSTANCE_PASS_DB
        
        # INJEÇÃO DO CÓDIGO PHP PARA RESOLVER O HEADER/HTTPS:
        export WORDPRESS_CONFIG_EXTRA='if (isset($_SERVER["HTTP_X_FORWARDED_PROTO"]) && $_SERVER["HTTP_X_FORWARDED_PROTO"] === "https") { $_SERVER["HTTPS"] = "on"; } else if (isset($_SERVER["HTTP_CLOUDFRONT_FORWARDED_PROTO"]) && $_SERVER["HTTP_CLOUDFRONT_FORWARDED_PROTO"] === "https") { $_SERVER["HTTPS"] = "on"; }'
        
        exec docker-entrypoint.sh apache2-foreground
      EOT]
    "privileged" = false
    "readonlyRootFilesystem" = false
    "logConfiguration" = {
    "logDriver" = "awslogs"
    "options" = {
    "awslogs-group" = aws_cloudwatch_log_group.WordPress.name
    "awslogs-region" = "us-east-1"
    "awslogs-stream-prefix" = "Container1"
  }
  }
  }
}

resource "aws_ecs_task_definition" "WordPress" {
  container_definitions             = jsonencode([local.container_def_WordPress_Container1])
  cpu                               = "1024"
  execution_role_arn                = aws_iam_role.execution_role_ecs_WordPress.arn
  family                            = "app"
  memory                            = "2048"
  network_mode                      = "awsvpc"
  requires_compatibilities          = ["FARGATE"]
  task_role_arn                     = aws_iam_role.task_role_ecs_WordPress.arn
  tags                              = {
    "Name" = "WordPress"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
  volume {
    name                            = "aws_efs_access_point_AP2"
    efs_volume_configuration {
      file_system_id                = "${aws_efs_file_system.EFS2.id}"
      transit_encryption            = "ENABLED"
      authorization_config {
        access_point_id             = "${aws_efs_access_point.AP2.id}"
        iam                         = "ENABLED"
      }
    }
  }
  depends_on                        = [aws_iam_role_policy_attachment.ecs_task_definition_WordPress_task_st_StatefulECS_attach, aws_iam_role_policy_attachment.ecs_task_definition_WordPress_execution_st_StatefulECS_attach]
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "WordPress" {
  name                              = "/aws/ecs/WordPress"
  log_group_class                   = "STANDARD"
  retention_in_days                 = 1
  skip_destroy                      = false
  tags                              = {
    "Name" = "WordPress"
    "State" = "StatefulECS"
    "CloudmanUser" = "Ricardo"
  }
}


