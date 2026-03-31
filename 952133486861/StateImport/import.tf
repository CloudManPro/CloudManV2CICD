terraform {
  backend "s3" {
    bucket = "cloudan-v2-cicd"
    key    = "952133486861/StateImport/main.tfstate"
    region = "us-east-1"
  }
}

import {
  to = aws_internet_gateway.project-igw
  id = "igw-0bc0c771ac5bc0b9a"
}

import {
  to = aws_subnet.project-subnet-public2-us-east-1b
  id = "subnet-06347d823f675902a"
}

import {
  to = aws_vpc.project-vpc
  id = "vpc-0e9867371edca7897"
}

import {
  to = aws_subnet.project-subnet-private1-us-east-1a
  id = "subnet-0e43b2411cc39adaa"
}

import {
  to = aws_subnet.project-subnet-public1-us-east-1a
  id = "subnet-0513422af8e2b954d"
}

import {
  to = aws_subnet.project-subnet-private2-us-east-1b
  id = "subnet-095d9faf3ab34f7ec"
}

import {
  to = aws_route_table.project-rtb-private1-us-east-1a
  id = "rtb-0d3d757f2257e19d6"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_private1_us_east_1a_project_rtb_private1_us_east_1a
  id = "subnet-0e4195cf9778b7f86/rtb-0d3d757f2257e19d6"
}

import {
  to = aws_route_table.project-rtb-public
  id = "rtb-03425df7ac6210892"
}

import {
  to = aws_route_table.project-rtb-private2-us-east-1b
  id = "rtb-073523f73f6341618"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_private2_us_east_1b_project_rtb_private2_us_east_1b
  id = "subnet-0de49bd19b99a661f/rtb-073523f73f6341618"
}

