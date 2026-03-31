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
    Name = "project-igw"
  }
  vpc_id = "vpc-09d6011eb1cd17f0d"
}

resource "aws_route" "aws_route_project_rtb_public_project_igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "igw-0d776d853817e2cb9"
  route_table_id = "rtb-018e0442daf6e3ded"
}

resource "aws_route_table" "project-rtb-private1-us-east-1a" {
  tags = {
    Name = "project-rtb-private1-us-east-1a"
  }
  vpc_id = "vpc-09d6011eb1cd17f0d"
}

resource "aws_route_table" "project-rtb-private2-us-east-1b" {
  tags = {
    Name = "project-rtb-private2-us-east-1b"
  }
  vpc_id = "vpc-09d6011eb1cd17f0d"
}

resource "aws_route_table" "project-rtb-public" {
  route {
    gateway_id = "igw-0d776d853817e2cb9"
    ipv6_cidr_block = "::/0"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-0d776d853817e2cb9"
  }
  tags = {
    Name = "project-rtb-public"
  }
  vpc_id = "vpc-09d6011eb1cd17f0d"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_private1_us_east_1a_project_rtb_private1_us_east_1a" {
  route_table_id = "rtb-0d3d757f2257e19d6"
  subnet_id = "subnet-0e4195cf9778b7f86"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_private2_us_east_1b_project_rtb_private2_us_east_1b" {
  route_table_id = "rtb-073523f73f6341618"
  subnet_id = "subnet-0de49bd19b99a661f"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_public1_us_east_1a_project_rtb_public" {
  route_table_id = "rtb-018e0442daf6e3ded"
  subnet_id = "subnet-06f1eb436fa1a94bd"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_public2_us_east_1b_project_rtb_public" {
  route_table_id = "rtb-018e0442daf6e3ded"
  subnet_id = "subnet-03341dacbf8e734c4"
}

resource "aws_subnet" "project-subnet-private1-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "10.0.128.0/25"
  ipv6_cidr_block = "2600:1f18:55da:b602::/64"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "project-subnet-private1-us-east-1a"
  }
  vpc_id = "vpc-09d6011eb1cd17f0d"
}

resource "aws_subnet" "project-subnet-private2-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "10.0.144.0/25"
  ipv6_cidr_block = "2600:1f18:55da:b603::/64"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "project-subnet-private2-us-east-1b"
  }
  vpc_id = "vpc-09d6011eb1cd17f0d"
}

resource "aws_subnet" "project-subnet-public1-us-east-1a" {
  availability_zone = "us-east-1a"
  cidr_block = "10.0.0.0/24"
  ipv6_cidr_block = "2600:1f18:55da:b600::/64"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "project-subnet-public1-us-east-1a"
  }
  vpc_id = "vpc-09d6011eb1cd17f0d"
}

resource "aws_subnet" "project-subnet-public2-us-east-1b" {
  availability_zone = "us-east-1b"
  cidr_block = "10.0.16.0/24"
  ipv6_cidr_block = "2600:1f18:55da:b601::/64"
  map_public_ip_on_launch = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name = "project-subnet-public2-us-east-1b"
  }
  vpc_id = "vpc-09d6011eb1cd17f0d"
}

resource "aws_vpc" "project-vpc" {
  assign_generated_ipv6_cidr_block = true
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
  ipv6_cidr_block = "2600:1f18:55da:b600::/56"
  ipv6_cidr_block_network_border_group = "us-east-1"
  tags = {
    Name = "project-vpc"
  }
}

