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
  to = aws_subnet.project-subnet-private2-us-east-1b
  id = "subnet-08c60b7ddb33a0e47"
}

import {
  to = aws_vpc.project-vpc
  id = "vpc-0b61653f5fbcdc5fb"
}

import {
  to = aws_subnet.project-subnet-private1-us-east-1a
  id = "subnet-0e49f7d42b6759b2b"
}

import {
  to = aws_subnet.project-subnet-public1-us-east-1a
  id = "subnet-0c41cdce4a4ecdd3a"
}

import {
  to = aws_subnet.project-subnet-public2-us-east-1b
  id = "subnet-049cfff09522aa1e8"
}

import {
  to = aws_route_table.project-rtb-private2-us-east-1b
  id = "rtb-03e66a9c5ae98a21b"
}

import {
  to = aws_route_table_association.project-rtb-private2-us-east-1b_subnet_08c60b7ddb33a0e47_rtb_03e66a9c5ae98a21b
  id = "subnet-08c60b7ddb33a0e47/rtb-03e66a9c5ae98a21b"
}

import {
  to = aws_route_table.project-rtb-public
  id = "rtb-0696e55dfe97754cf"
}

import {
  to = aws_route.project-rtb-public_rtb_0696e55dfe97754cf_0_0_0_0_0
  id = "rtb-0696e55dfe97754cf_0.0.0.0/0"
}

import {
  to = aws_route_table_association.project-rtb-public_subnet_0c41cdce4a4ecdd3a_rtb_0696e55dfe97754cf
  id = "subnet-0c41cdce4a4ecdd3a/rtb-0696e55dfe97754cf"
}

import {
  to = aws_route_table_association.project-rtb-public_subnet_049cfff09522aa1e8_rtb_0696e55dfe97754cf
  id = "subnet-049cfff09522aa1e8/rtb-0696e55dfe97754cf"
}

import {
  to = aws_route_table.project-rtb-private1-us-east-1a
  id = "rtb-0d5c508a116780221"
}

import {
  to = aws_route_table_association.project-rtb-private1-us-east-1a_subnet_0e49f7d42b6759b2b_rtb_0d5c508a116780221
  id = "subnet-0e49f7d42b6759b2b/rtb-0d5c508a116780221"
}

