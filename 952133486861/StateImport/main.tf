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

resource "aws_internet_gateway" "project-igw" {
  tags = {
    CloudmanUser = "Ricardo"
    Name = "project-igw"
    State = "StateImport"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_route_table" "project-rtb-private1-us-east-1a" {
  tags = {
    CloudmanUser = "Ricardo"
    Name = "project-rtb-private1-us-east-1a"
    State = "StateImport"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_route_table" "project-rtb-private2-us-east-1b" {
  tags = {
    CloudmanUser = "Ricardo"
    Name = "project-rtb-private2-us-east-1b"
    State = "StateImport"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_route_table" "project-rtb-public" {
  tags = {
    CloudmanUser = "Ricardo"
    Name = "project-rtb-public"
    State = "StateImport"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_private1_us_east_1a_project_rtb_private1_us_east_1a" {
  route_table_id = "rtb-028df10705a741286"
  subnet_id = "subnet-0307b94f20ac32d25"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_private2_us_east_1b_project_rtb_private2_us_east_1b" {
  route_table_id = "rtb-0ef1ea668cc336fd1"
  subnet_id = "subnet-02240d2966cd8bb35"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_public1_us_east_1a_project_rtb_public" {
  route_table_id = "rtb-011e4b9b17e1e55c5"
  subnet_id = "subnet-0ad858da04a904b29"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_public2_us_east_1b_project_rtb_public" {
  route_table_id = "rtb-011e4b9b17e1e55c5"
  subnet_id = "subnet-02beeb50a9b6c85ff"
}

resource "aws_subnet" "project-subnet-private1-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "10.0.128.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    CloudmanUser = "Ricardo"
    Name = "project-subnet-private1-us-east-1a"
    State = "StateImport"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_subnet" "project-subnet-private2-us-east-1b" {
  availability_zone = "us-east-1a"
  cidr_block = "10.0.144.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    CloudmanUser = "Ricardo"
    Name = "project-subnet-private2-us-east-1b"
    State = "StateImport"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_subnet" "project-subnet-public1-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "10.0.0.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    CloudmanUser = "Ricardo"
    Name = "project-subnet-public1-us-east-1a"
    State = "StateImport"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_subnet" "project-subnet-public2-us-east-1b" {
  availability_zone = "us-east-1a"
  cidr_block = "10.0.16.0/20"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    CloudmanUser = "Ricardo"
    Name = "project-subnet-public2-us-east-1b"
    State = "StateImport"
  }
  vpc_id = "vpc-0caa7b6bdff63699a"
}

resource "aws_vpc" "project-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
  tags = {
    CloudmanUser = "Ricardo"
    Name = "project-vpc"
    State = "StateImport"
  }
}

