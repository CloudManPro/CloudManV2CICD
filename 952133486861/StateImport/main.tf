terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "cloudan-v2-cicd"
    key    = "952133486861/StateImport/main.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "Inst" {
  ami = "ami-07588980091994c40"
  associate_public_ip_address = false
  availability_zone = "us-east-1a"
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  cpu_options {
    core_count = 2
    threads_per_core = 1
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  ebs_optimized = true
  enclave_options {
    enabled = false
  }
  instance_initiated_shutdown_behavior = "terminate"
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
      max_price = "0.004200"
      spot_instance_type = "one-time"
    }
  }
  instance_type = "t4g.nano"
  maintenance_options {
    auto_recovery = "default"
  }
  metadata_options {
    http_endpoint = "enabled"
    http_protocol_ipv6 = "disabled"
    http_put_response_hop_limit = 2
    http_tokens = "required"
    instance_metadata_tags = "disabled"
  }
  private_dns_name_options {
    enable_resource_name_dns_a_record = false
    enable_resource_name_dns_aaaa_record = false
    hostname_type = "ip-name"
  }
  private_ip = "10.0.142.166"
  region = "us-east-1"
  root_block_device {
    delete_on_termination = true
    encrypted = false
    iops = 3000
    throughput = 125
    volume_size = 8
    volume_type = "gp3"
  }
  subnet_id = "subnet-0e7556fa994ef548d"
  tags = {
    Name = "Inst"
  }
  tags_all = {
    Name = "Inst"
  }
  vpc_security_group_ids = ["sg-00e1c5d428577c30f"]
}

resource "aws_internet_gateway" "prj-igw" {
  tags = {
    CloudmanUser = "Ricardo"
    Name = "prj-igw"
    State = "StateImport"
  }
  vpc_id = "vpc-0b4a879f0ed7c3670"
}

resource "aws_route" "aws_route_prj_rtb_public_prj_igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "igw-0228f8c08a73676a2"
  route_table_id = "rtb-0765224565bf16937"
}

resource "aws_route_table" "prj-rtb-private1-us-east-1a" {
  tags = {
    CloudmanUser = "Ricardo"
    Name = "prj-rtb-private1-us-east-1a"
    State = "StateImport"
  }
  vpc_id = "vpc-0b4a879f0ed7c3670"
}

resource "aws_route_table" "prj-rtb-private2-us-east-1b" {
  tags = {
    CloudmanUser = "Ricardo"
    Name = "prj-rtb-private2-us-east-1b"
    State = "StateImport"
  }
  vpc_id = "vpc-0b4a879f0ed7c3670"
}

resource "aws_route_table" "prj-rtb-public" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0228f8c08a73676a2"
  }
  tags = {
    CloudmanUser = "Ricardo"
    Name = "prj-rtb-public"
    State = "StateImport"
  }
  vpc_id = "vpc-0b4a879f0ed7c3670"
}

resource "aws_route_table_association" "aws_route_table_association_prj_subnet_private1_us_east_1a_prj_rtb_private1_us_east_1a" {
  route_table_id = "rtb-029de9f8107c53070"
  subnet_id = "subnet-0e7556fa994ef548d"
}

resource "aws_route_table_association" "aws_route_table_association_prj_subnet_private2_us_east_1b_prj_rtb_private2_us_east_1b" {
  route_table_id = "rtb-0ef03df7833f70dd9"
  subnet_id = "subnet-09457a1536c9373dc"
}

resource "aws_route_table_association" "aws_route_table_association_prj_subnet_public1_us_east_1a_prj_rtb_public" {
  route_table_id = "rtb-0765224565bf16937"
  subnet_id = "subnet-0930ef051bf741071"
}

resource "aws_route_table_association" "aws_route_table_association_prj_subnet_public2_us_east_1b_prj_rtb_public" {
  route_table_id = "rtb-0765224565bf16937"
  subnet_id = "subnet-047baeae858321f71"
}

resource "aws_subnet" "prj-subnet-private1-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "10.0.128.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    CloudmanUser = "Ricardo"
    Name = "prj-subnet-private1-us-east-1a"
    State = "StateImport"
  }
  vpc_id = "vpc-0b4a879f0ed7c3670"
}

resource "aws_subnet" "prj-subnet-private2-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "10.0.144.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    CloudmanUser = "Ricardo"
    Name = "prj-subnet-private2-us-east-1b"
    State = "StateImport"
  }
  vpc_id = "vpc-0b4a879f0ed7c3670"
}

resource "aws_subnet" "prj-subnet-public1-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "10.0.0.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    CloudmanUser = "Ricardo"
    Name = "prj-subnet-public1-us-east-1a"
    State = "StateImport"
  }
  vpc_id = "vpc-0b4a879f0ed7c3670"
}

resource "aws_subnet" "prj-subnet-public2-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "10.0.16.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    CloudmanUser = "Ricardo"
    Name = "prj-subnet-public2-us-east-1b"
    State = "StateImport"
  }
  vpc_id = "vpc-0b4a879f0ed7c3670"
}

resource "aws_vpc" "prj-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
  tags = {
    CloudmanUser = "Ricardo"
    Name = "prj-vpc"
    State = "StateImport"
  }
}

