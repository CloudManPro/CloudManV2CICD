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

resource "aws_vpc" "prj-vpc" {
  cidr_block                        = "10.0.0.0/16"
  enable_dns_hostnames              = true
  enable_dns_support                = true
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "prj-vpc"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "prj-subnet-private1-us-east-1a" {
  vpc_id                            = aws_vpc.prj-vpc.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.128.0/20"
  map_public_ip_on_launch           = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags                              = {
    "Name" = "prj-subnet-private1-us-east-1a"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "prj-subnet-private2-us-east-1b" {
  vpc_id                            = aws_vpc.prj-vpc.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.144.0/20"
  map_public_ip_on_launch           = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags                              = {
    "Name" = "prj-subnet-private2-us-east-1b"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "prj-subnet-public1-us-east-1a" {
  vpc_id                            = aws_vpc.prj-vpc.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.0.0/20"
  map_public_ip_on_launch           = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags                              = {
    "Name" = "prj-subnet-public1-us-east-1a"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_subnet" "prj-subnet-public2-us-east-1b" {
  vpc_id                            = aws_vpc.prj-vpc.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.16.0/20"
  map_public_ip_on_launch           = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags                              = {
    "Name" = "prj-subnet-public2-us-east-1b"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_internet_gateway" "prj-igw" {
  vpc_id                            = aws_vpc.prj-vpc.id
  tags                              = {
    "Name" = "prj-igw"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_route" "aws_route_prj_rtb_public_prj_igw" {
  gateway_id                        = aws_internet_gateway.prj-igw.id
  route_table_id                    = aws_route_table.prj-rtb-public.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "prj-rtb-private1-us-east-1a" {
  vpc_id                            = aws_vpc.prj-vpc.id
  tags                              = {
    "Name" = "prj-rtb-private1-us-east-1a"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_route_table" "prj-rtb-private2-us-east-1b" {
  vpc_id                            = aws_vpc.prj-vpc.id
  tags                              = {
    "Name" = "prj-rtb-private2-us-east-1b"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_route_table" "prj-rtb-public" {
  vpc_id                            = aws_vpc.prj-vpc.id
  tags                              = {
    "Name" = "prj-rtb-public"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_route_table_association" "aws_route_table_association_prj_subnet_private1_us_east_1a_prj_rtb_private1_us_east_1a" {
  route_table_id                    = aws_route_table.prj-rtb-private1-us-east-1a.id
  subnet_id                         = aws_subnet.prj-subnet-private1-us-east-1a.id
}

resource "aws_route_table_association" "aws_route_table_association_prj_subnet_private2_us_east_1b_prj_rtb_private2_us_east_1b" {
  route_table_id                    = aws_route_table.prj-rtb-private2-us-east-1b.id
  subnet_id                         = aws_subnet.prj-subnet-private2-us-east-1b.id
}

resource "aws_route_table_association" "aws_route_table_association_prj_subnet_public1_us_east_1a_prj_rtb_public" {
  route_table_id                    = aws_route_table.prj-rtb-public.id
  subnet_id                         = aws_subnet.prj-subnet-public1-us-east-1a.id
}

resource "aws_route_table_association" "aws_route_table_association_prj_subnet_public2_us_east_1b_prj_rtb_public" {
  route_table_id                    = aws_route_table.prj-rtb-public.id
  subnet_id                         = aws_subnet.prj-subnet-public2-us-east-1b.id
}


