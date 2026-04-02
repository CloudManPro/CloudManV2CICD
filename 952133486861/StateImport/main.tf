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

resource "aws_internet_gateway" "prj-igw" {
  tags = {
    Name = "prj-igw"
  }
  vpc_id = "vpc-0931926afa7488760"
}

resource "aws_route" "prj-rtb-public_rtb_083c0136e4564dea5_0_0_0_0_0" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "igw-01a5cd2e6fcdae7ba"
  route_table_id = "rtb-083c0136e4564dea5"
}

resource "aws_route_table" "prj-rtb-private1-us-east-1a" {
  tags = {
    Name = "prj-rtb-private1-us-east-1a"
  }
  vpc_id = "vpc-0931926afa7488760"
}

resource "aws_route_table" "prj-rtb-private2-us-east-1b" {
  tags = {
    Name = "prj-rtb-private2-us-east-1b"
  }
  vpc_id = "vpc-0931926afa7488760"
}

resource "aws_route_table" "prj-rtb-public" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-01a5cd2e6fcdae7ba"
  }
  tags = {
    Name = "prj-rtb-public"
  }
  vpc_id = "vpc-0931926afa7488760"
}

resource "aws_route_table_association" "prj-rtb-private1-us-east-1a_subnet_0700fd2cb99b5c9b8_rtb_04d87a9569beb1880" {
  route_table_id = "rtb-04d87a9569beb1880"
  subnet_id = "subnet-0700fd2cb99b5c9b8"
}

resource "aws_route_table_association" "prj-rtb-private2-us-east-1b_subnet_0176fefeeed75d7f5_rtb_00390fd114c1c6a2f" {
  route_table_id = "rtb-00390fd114c1c6a2f"
  subnet_id = "subnet-0176fefeeed75d7f5"
}

resource "aws_route_table_association" "prj-rtb-public_subnet_02042bee71db89c81_rtb_083c0136e4564dea5" {
  route_table_id = "rtb-083c0136e4564dea5"
  subnet_id = "subnet-02042bee71db89c81"
}

resource "aws_route_table_association" "prj-rtb-public_subnet_02952a1b32c034dd2_rtb_083c0136e4564dea5" {
  route_table_id = "rtb-083c0136e4564dea5"
  subnet_id = "subnet-02952a1b32c034dd2"
}

resource "aws_subnet" "prj-subnet-private1-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "10.3.128.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "prj-subnet-private1-us-east-1a"
  }
  vpc_id = "vpc-0931926afa7488760"
}

resource "aws_subnet" "prj-subnet-private2-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "10.3.144.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "prj-subnet-private2-us-east-1b"
  }
  vpc_id = "vpc-0931926afa7488760"
}

resource "aws_subnet" "prj-subnet-public1-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "10.3.0.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "prj-subnet-public1-us-east-1a"
  }
  vpc_id = "vpc-0931926afa7488760"
}

resource "aws_subnet" "prj-subnet-public2-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "10.3.16.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "prj-subnet-public2-us-east-1b"
  }
  vpc_id = "vpc-0931926afa7488760"
}

resource "aws_vpc" "prj-vpc" {
  cidr_block = "10.3.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
  tags = {
    Name = "prj-vpc"
  }
}

