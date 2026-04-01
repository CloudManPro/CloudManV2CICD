terraform {
  backend "s3" {
    bucket = "cloudan-v2-cicd"
    key    = "952133486861/StateImport/main.tfstate"
    region = "us-east-1"
  }
}

import {
  to = aws_vpc.project-vpc
  id = "vpc-0aa413081b1a16aa1"
}

import {
  to = aws_internet_gateway.project-igw
  id = "igw-06e86779d555b6bcf"
}

import {
  to = aws_subnet.project-subnet-public1-us-east-1a
  id = "subnet-07313a9f351436173"
}

import {
  to = aws_subnet.project-subnet-private2-us-east-1b
  id = "subnet-07af2d8dab282fd0b"
}

import {
  to = aws_subnet.project-subnet-public2-us-east-1b
  id = "subnet-061e9f909753167db"
}

import {
  to = aws_subnet.project-subnet-private1-us-east-1a
  id = "subnet-0c615d34d43cddbb8"
}

import {
  to = aws_instance.testi
  id = ""
}

import {
  to = aws_route_table.project-rtb-private2-us-east-1b
  id = "rtb-033947f453b929c60"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_private2_us_east_1b_project_rtb_private2_us_east_1b
  id = "rtbassoc-006fbbbf84ab8991b"
}

import {
  to = aws_route_table.project-rtb-public
  id = "rtb-02aa4bbd6ae0d2850"
}

import {
  to = aws_route.aws_route_project_rtb_public_project_igw
  id = "rtb-02aa4bbd6ae0d2850_0.0.0.0/0"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_public1_us_east_1a_project_rtb_public
  id = "rtbassoc-090f0090aecd018bc"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_public2_us_east_1b_project_rtb_public
  id = "rtbassoc-0b34e5736e5d43412"
}

import {
  to = aws_route_table.project-rtb-private1-us-east-1a
  id = "rtb-02f5383675c85e08c"
}

import {
  to = aws_route_table_association.aws_route_table_association_project_subnet_private1_us_east_1a_project_rtb_private1_us_east_1a
  id = "rtbassoc-0cf203dd249cf5059"
}

