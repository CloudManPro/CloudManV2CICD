terraform {
  backend "s3" {
    bucket = "cloudan-v2-cicd"
    key    = "952133486861/StateImport/main.tfstate"
    region = "us-east-1"
  }
}

import {
  to = aws_subnet.project-subnet-private2-us-east-1b
  id = "subnet-0748f1f18048924e9"
}

import {
  to = aws_subnet.project-subnet-private1-us-east-1a
  id = "subnet-02266d6c27377d5cc"
}

import {
  to = aws_subnet.project-subnet-public1-us-east-1a
  id = "subnet-0bf33e81c0ccc51d4"
}

import {
  to = aws_subnet.project-subnet-public2-us-east-1b
  id = "subnet-0e5baa41a766fd249"
}

import {
  to = aws_internet_gateway.project-igw
  id = "igw-06984605e0f0d90b0"
}

import {
  to = aws_vpc.project-vpc
  id = "vpc-0dae32a7f2c046aa2"
}

import {
  to = aws_route_table.project-rtb-private1-us-east-1a
  id = "rtb-0a43b784cd4a3ca78"
}

import {
  to = aws_route.project-rtb-private1-us-east-1a_rtb_0a43b784cd4a3ca78_None
  id = "rtb-0a43b784cd4a3ca78_None"
}

import {
  to = aws_route_table_association.project-rtb-private1-us-east-1a_subnet_02266d6c27377d5cc_rtb_0a43b784cd4a3ca78
  id = "subnet-02266d6c27377d5cc/rtb-0a43b784cd4a3ca78"
}

import {
  to = aws_route_table.project-rtb-public
  id = "rtb-09a0561cd983e8530"
}

import {
  to = aws_route.project-rtb-public_rtb_09a0561cd983e8530_0_0_0_0_0
  id = "rtb-09a0561cd983e8530_0.0.0.0/0"
}

import {
  to = aws_route.project-rtb-public_rtb_09a0561cd983e8530_None
  id = "rtb-09a0561cd983e8530_None"
}

import {
  to = aws_route_table_association.project-rtb-public_subnet_0e5baa41a766fd249_rtb_09a0561cd983e8530
  id = "subnet-0e5baa41a766fd249/rtb-09a0561cd983e8530"
}

import {
  to = aws_route_table_association.project-rtb-public_subnet_0bf33e81c0ccc51d4_rtb_09a0561cd983e8530
  id = "subnet-0bf33e81c0ccc51d4/rtb-09a0561cd983e8530"
}

import {
  to = aws_route_table.project-rtb-private2-us-east-1b
  id = "rtb-0f3a93563ec043779"
}

import {
  to = aws_route.project-rtb-private2-us-east-1b_rtb_0f3a93563ec043779_None
  id = "rtb-0f3a93563ec043779_None"
}

import {
  to = aws_route_table_association.project-rtb-private2-us-east-1b_subnet_0748f1f18048924e9_rtb_0f3a93563ec043779
  id = "subnet-0748f1f18048924e9/rtb-0f3a93563ec043779"
}

