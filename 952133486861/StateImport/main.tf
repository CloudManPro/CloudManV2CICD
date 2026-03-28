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

	resource "aws_route" "project-rtb-public_rtb_0696e55dfe97754cf_0_0_0_0_0" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "igw-0df108f2d8c806e33"
  route_table_id = "rtb-0696e55dfe97754cf"
}

resource "aws_subnet" "project-subnet-private1-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "192.168.8.0/24"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "project-subnet-private1-us-east-1a"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

resource "aws_subnet" "project-subnet-private2-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "192.168.9.0/24"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "project-subnet-private2-us-east-1b"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

resource "aws_subnet" "project-subnet-public1-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "192.168.0.0/24"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "project-subnet-public1-us-east-1a"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

resource "aws_subnet" "project-subnet-public2-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "project-subnet-public2-us-east-1b"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

