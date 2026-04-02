terraform {
  backend "s3" {
    bucket = "cloudan-v2-cicd"
    key    = "952133486861/StateImport/main.tfstate"
    region = "us-east-1"
  }
}

import {
  to = aws_subnet.project-subnet-private1-us-east-1a
  id = "subnet-0307b94f20ac32d25"
}

import {
  to = aws_subnet.project-subnet-public2-us-east-1b
  id = "subnet-009370f0cafef4268"
}

import {
  to = aws_internet_gateway.project-igw
  id = "igw-0a0f17c85e4f52817"
}

import {
  to = aws_subnet.project-subnet-private2-us-east-1b
  id = "subnet-0770ac3aeb35146f4"
}

import {
  to = aws_vpc.project-vpc
  id = "vpc-0caa7b6bdff63699a"
}

import {
  to = aws_subnet.project-subnet-public1-us-east-1a
  id = "subnet-02beeb50a9b6c85ff"
}

import {
  to = aws_route_table.project-rtb-private2-us-east-1b
  id = "rtb-0ef1ea668cc336fd1"
}

import {
  to = aws_route_table_association.project-rtb-private2-us-east-1b_subnet_0770ac3aeb35146f4_rtb_0ef1ea668cc336fd1
  id = "subnet-0770ac3aeb35146f4/rtb-0ef1ea668cc336fd1"
}

import {
  to = aws_route_table.project-rtb-public
  id = "rtb-011e4b9b17e1e55c5"
}

import {
  to = aws_route.project-rtb-public_rtb_011e4b9b17e1e55c5_0_0_0_0_0
  id = "rtb-011e4b9b17e1e55c5_0.0.0.0/0"
}

import {
  to = aws_route_table_association.project-rtb-public_subnet_02beeb50a9b6c85ff_rtb_011e4b9b17e1e55c5
  id = "subnet-02beeb50a9b6c85ff/rtb-011e4b9b17e1e55c5"
}

import {
  to = aws_route_table_association.project-rtb-public_subnet_009370f0cafef4268_rtb_011e4b9b17e1e55c5
  id = "subnet-009370f0cafef4268/rtb-011e4b9b17e1e55c5"
}

import {
  to = aws_route_table.project-rtb-private1-us-east-1a
  id = "rtb-028df10705a741286"
}

import {
  to = aws_route_table_association.project-rtb-private1-us-east-1a_subnet_0307b94f20ac32d25_rtb_028df10705a741286
  id = "subnet-0307b94f20ac32d25/rtb-028df10705a741286"
}

import {
  to = aws_instance.test
  id = "i-01d8ec96be1f5797d"
}

