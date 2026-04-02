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
  instance_tenancy                  = "default"
}

resource "aws_internet_gateway" "project-igw" {
  vpc_id                            = aws_vpc.project-vpc.id
  tags                              = {
    "Name" = "project-igw"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_route_table" "project-rtb-private1-us-east-1a" {
  vpc_id                            = aws_vpc.project-vpc.id
  tags                              = {
    "Name" = "project-rtb-private1-us-east-1a"
    "State" = "StateImport"
    "CloudmanUser" = "Ricardo"
  }
}

resource "aws_route_table" "project-rtb-private2-us-east-1b" {
  vpc_id                            = aws_vpc.project-vpc.id
  tags                              = {
    "Name" = "project-rtb-private2-us-east-1b"
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

resource "aws_route_table_association" "aws_route_table_association_project_subnet_private1_us_east_1a_project_rtb_private1_us_east_1a" {
  route_table_id                    = aws_route_table.project-rtb-private1-us-east-1a.id
  subnet_id                         = aws_subnet.project-subnet-private1-us-east-1a.id
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_private2_us_east_1b_project_rtb_private2_us_east_1b" {
  route_table_id                    = aws_route_table.project-rtb-private2-us-east-1b.id
  subnet_id                         = aws_subnet.project-subnet-private2-us-east-1b.id
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_public1_us_east_1a_project_rtb_public" {
  route_table_id                    = aws_route_table.project-rtb-public.id
  subnet_id                         = aws_subnet.project-subnet-public1-us-east-1a.id
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_public2_us_east_1b_project_rtb_public" {
  route_table_id                    = aws_route_table.project-rtb-public.id
  subnet_id                         = aws_subnet.project-subnet-public2-us-east-1b.id
}


