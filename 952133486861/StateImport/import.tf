terraform {
  backend "s3" {
    bucket = "cloudan-v2-cicd"
    key    = "952133486861/StateImport/main.tfstate"
    region = "us-east-1"
  }
}

import {
  to = aws_internet_gateway.project-igw
  id = "igw-0df108f2d8c806e33"
}

import {
  to = aws_subnet.project-subnet-private1-us-east-1a
  id = ""
}

import {
  to = aws_subnet.project-subnet-private1-us-east-1a
  id = ""
}

import {
  to = aws_subnet.project-subnet-private1-us-east-1a
  id = ""
}

import {
  to = aws_subnet.project-subnet-private1-us-east-1a
  id = ""
}

import {
  to = aws_vpc.project-vpc
  id = "vpc-0b61653f5fbcdc5fb"
}

import {
  to = aws_route_table.project-subnet-private1-us-east-1a
  id = ""
}

