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

resource "aws_route" "aws_route_project_rtb_public_project_igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "igw-0a0f17c85e4f52817"
  route_table_id = "rtb-011e4b9b17e1e55c5"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_private1_us_east_1a_project_rtb_private1_us_east_1a" {
  route_table_id = "rtb-028df10705a741286"
  subnet_id = "subnet-0307b94f20ac32d25"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_private2_us_east_1b_project_rtb_private2_us_east_1b" {
  route_table_id = "rtb-0ef1ea668cc336fd1"
  subnet_id = "subnet-0770ac3aeb35146f4"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_public1_us_east_1a_project_rtb_public" {
  route_table_id = "rtb-011e4b9b17e1e55c5"
  subnet_id = "subnet-02beeb50a9b6c85ff"
}

resource "aws_route_table_association" "aws_route_table_association_project_subnet_public2_us_east_1b_project_rtb_public" {
  route_table_id = "rtb-011e4b9b17e1e55c5"
  subnet_id = "subnet-009370f0cafef4268"
}

