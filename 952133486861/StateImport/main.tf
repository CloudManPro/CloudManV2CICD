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

resource "aws_route_table_association" "aws_route_table_association_project_subnet_private1_us_east_1a_project_rtb_private1_us_east_1a" {
  route_table_id = "rtb-0d3d757f2257e19d6"
  subnet_id = "subnet-0e4195cf9778b7f86"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_private2_us_east_1b_project_rtb_private2_us_east_1b" {
  route_table_id = "rtb-073523f73f6341618"
  subnet_id = "subnet-0de49bd19b99a661f"
}

