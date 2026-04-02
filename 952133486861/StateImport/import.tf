terraform {
  backend "s3" {
    bucket = "cloudan-v2-cicd"
    key    = "952133486861/StateImport/main.tfstate"
    region = "us-east-1"
  }
}

import {
  to = aws_internet_gateway.project-igw
  id = "igw-0a0f17c85e4f52817"
}

import {
  to = aws_subnet.project-subnet-private1-us-east-1a
  id = "subnet-0307b94f20ac32d25"
}

import {
  to = aws_subnet.project-subnet-private2-us-east-1b
  id = "subnet-02240d2966cd8bb35"
}

import {
  to = aws_subnet.project-subnet-public2-us-east-1b
  id = "subnet-0ad858da04a904b29"
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
  to = aws_route_table.project-rtb-private1-us-east-1a
  id = "rtb-028df10705a741286"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_private1_us_east_1a_project_rtb_private1_us_east_1a
  id = "subnet-0307b94f20ac32d25/rtb-028df10705a741286"
}

import {
  to = aws_route_table.project-rtb-private2-us-east-1b
  id = "rtb-0ef1ea668cc336fd1"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_private2_us_east_1b_project_rtb_private2_us_east_1b
  id = "subnet-02240d2966cd8bb35/rtb-0ef1ea668cc336fd1"
}

import {
  to = aws_route_table.project-rtb-public
  id = "rtb-011e4b9b17e1e55c5"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_public1_us_east_1a_project_rtb_public
  id = "subnet-0ad858da04a904b29/rtb-011e4b9b17e1e55c5"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_public2_us_east_1b_project_rtb_public
  id = "subnet-02beeb50a9b6c85ff/rtb-011e4b9b17e1e55c5"
}

