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

resource "aws_instance" "test" {
  ami = "ami-037d882b31eae26a2"
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
  private_ip = "10.0.130.110"
  region = "us-east-1"
  root_block_device {
    delete_on_termination = true
    encrypted = false
    iops = 3000
    throughput = 125
    volume_size = 8
    volume_type = "gp3"
  }
  subnet_id = "subnet-0307b94f20ac32d25"
  tags = {
    Name = "test"
  }
  tags_all = {
    Name = "test"
  }
  vpc_security_group_ids = ["sg-0377a3337c8412cc8"]
}

resource "aws_internet_gateway" "project-igw" {
  tags = {
    Name = "project-igw"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_route" "project-rtb-public_rtb_011e4b9b17e1e55c5_0_0_0_0_0" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "igw-0a0f17c85e4f52817"
  route_table_id = "rtb-011e4b9b17e1e55c5"
}

resource "aws_route_table" "project-rtb-private1-us-east-1a" {
  tags = {
    Name = "project-rtb-private1-us-east-1a"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_route_table" "project-rtb-private2-us-east-1b" {
  tags = {
    Name = "project-rtb-private2-us-east-1b"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_route_table" "project-rtb-public" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0a0f17c85e4f52817"
  }
  tags = {
    Name = "project-rtb-public"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_route_table_association" "project-rtb-private1-us-east-1a_subnet_0307b94f20ac32d25_rtb_028df10705a741286" {
  route_table_id = "rtb-028df10705a741286"
  subnet_id = "subnet-0307b94f20ac32d25"
}

resource "aws_route_table_association" "project-rtb-private2-us-east-1b_subnet_0770ac3aeb35146f4_rtb_0ef1ea668cc336fd1" {
  route_table_id = "rtb-0ef1ea668cc336fd1"
  subnet_id = "subnet-0770ac3aeb35146f4"
}

resource "aws_route_table_association" "project-rtb-public_subnet_009370f0cafef4268_rtb_011e4b9b17e1e55c5" {
  route_table_id = "rtb-011e4b9b17e1e55c5"
  subnet_id = "subnet-009370f0cafef4268"
}

resource "aws_route_table_association" "project-rtb-public_subnet_02beeb50a9b6c85ff_rtb_011e4b9b17e1e55c5" {
  route_table_id = "rtb-011e4b9b17e1e55c5"
  subnet_id = "subnet-02beeb50a9b6c85ff"
}

resource "aws_subnet" "project-subnet-private1-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "10.0.128.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "project-subnet-private1-us-east-1a"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_subnet" "project-subnet-private2-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "10.0.144.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "project-subnet-private2-us-east-1b"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_subnet" "project-subnet-public1-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "10.0.0.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "project-subnet-public1-us-east-1a"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_subnet" "project-subnet-public2-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "10.0.16.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "project-subnet-public2-us-east-1b"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_vpc" "project-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
  tags = {
    Name = "project-vpc"
  }
}

