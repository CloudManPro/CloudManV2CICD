terraform {
  backend "s3" {
    bucket = "cloudan-v2-cicd"
    key    = "952133486861/StateImport/main.tfstate"
    region = "us-east-1"
  }
}

import {
  to = aws_internet_gateway.project-igw
  id = "igw-0d776d853817e2cb9"
}

import {
  to = aws_subnet.project-subnet-public2-us-east-1b
  id = "subnet-03341dacbf8e734c4"
}

import {
  to = aws_vpc.project-vpc
  id = "vpc-09d6011eb1cd17f0d"
}

import {
  to = aws_subnet.project-subnet-private1-us-east-1a
  id = "subnet-0e4195cf9778b7f86"
}

import {
  to = aws_subnet.project-subnet-public1-us-east-1a
  id = "subnet-06f1eb436fa1a94bd"
}

import {
  to = aws_subnet.project-subnet-private2-us-east-1b
  id = "subnet-0de49bd19b99a661f"
}

import {
  to = aws_route_table.project-rtb-private2-us-east-1b
  id = "rtb-073523f73f6341618"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_private2_us_east_1b_project_rtb_private2_us_east_1b
  id = "subnet-0de49bd19b99a661f/rtb-073523f73f6341618"
}

import {
  to = aws_route_table.project-rtb-public
  id = "rtb-018e0442daf6e3ded"
}

import {
  to = aws_route.aws_route_project_rtb_public_project_igw
  id = "rtb-018e0442daf6e3ded_0.0.0.0/0"
}

import {
  to = aws_route.project-rtb-public_rtb_018e0442daf6e3ded_None
  id = "rtb-018e0442daf6e3ded_None"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_public1_us_east_1a_project_rtb_public
  id = "subnet-06f1eb436fa1a94bd/rtb-018e0442daf6e3ded"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_public2_us_east_1b_project_rtb_public
  id = "subnet-03341dacbf8e734c4/rtb-018e0442daf6e3ded"
}

import {
  to = aws_route_table.project-rtb-private1-us-east-1a
  id = "rtb-0d3d757f2257e19d6"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_private1_us_east_1a_project_rtb_private1_us_east_1a
  id = "subnet-0e4195cf9778b7f86/rtb-0d3d757f2257e19d6"
}

