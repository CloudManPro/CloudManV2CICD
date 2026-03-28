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
    key            = "952133486861/StateImport/main.tfstate"
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

resource "aws_vpc" "project-vpc" {
  cidr_block                        = "192.168.0.0/20"
  enable_dns_hostnames              = true
  enable_dns_support                = true
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "project-vpc"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "project-subnet-private1-us-east-1a" {
  vpc_id                            = aws_vpc.project-vpc.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "192.168.8.0/24"
  map_public_ip_on_launch           = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags                              = {
    "Name" = "project-subnet-private1-us-east-1a"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "project-subnet-private2-us-east-1b" {
  vpc_id                            = aws_vpc.project-vpc.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "192.168.9.0/24"
  map_public_ip_on_launch           = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags                              = {
    "Name" = "project-subnet-private2-us-east-1b"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "project-subnet-public1-us-east-1a" {
  vpc_id                            = aws_vpc.project-vpc.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "192.168.0.0/24"
  map_public_ip_on_launch           = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags                              = {
    "Name" = "project-subnet-public1-us-east-1a"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "project-subnet-public2-us-east-1b" {
  vpc_id                            = aws_vpc.project-vpc.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "192.168.1.0/24"
  map_public_ip_on_launch           = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags                              = {
    "Name" = "project-subnet-public2-us-east-1b"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_internet_gateway" "project-igw" {
  vpc_id                            = aws_vpc.project-vpc.id
  tags                              = {
    "Name" = "project-igw"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_route_table" "project-rtb-public" {
  vpc_id                            = aws_vpc.project-vpc.id
  tags                              = {
    "Name" = "project-rtb-public"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}


