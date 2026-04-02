terraform {
  backend "s3" {
    bucket = "cloudan-v2-cicd"
    key    = "952133486861/StateImport/main.tfstate"
    region = "us-east-1"
  }
}

import {
  to = aws_subnet.prj-subnet-public1-us-east-1a
  id = "subnet-0930ef051bf741071"
}

import {
  to = aws_subnet.prj-subnet-private2-us-east-1b
  id = "subnet-09457a1536c9373dc"
}

import {
  to = aws_subnet.prj-subnet-private1-us-east-1a
  id = "subnet-0e7556fa994ef548d"
}

import {
  to = aws_vpc.prj-vpc
  id = "vpc-0b4a879f0ed7c3670"
}

import {
  to = aws_subnet.prj-subnet-public2-us-east-1b
  id = "subnet-047baeae858321f71"
}

import {
  to = aws_internet_gateway.prj-igw
  id = "igw-0228f8c08a73676a2"
}

import {
  to = aws_route_table.prj-rtb-private2-us-east-1b
  id = "rtb-0ef03df7833f70dd9"
}

import {
  to = aws_route_table_association.aws_route_table_association_prj_subnet_private2_us_east_1b_prj_rtb_private2_us_east_1b
  id = "subnet-09457a1536c9373dc/rtb-0ef03df7833f70dd9"
}

import {
  to = aws_route_table.prj-rtb-public
  id = "rtb-0765224565bf16937"
}

import {
  to = aws_route.aws_route_prj_rtb_public_prj_igw
  id = "rtb-0765224565bf16937_0.0.0.0/0"
}

import {
  to = aws_route_table_association.aws_route_table_association_prj_subnet_public1_us_east_1a_prj_rtb_public
  id = "subnet-0930ef051bf741071/rtb-0765224565bf16937"
}

import {
  to = aws_route_table_association.aws_route_table_association_prj_subnet_public2_us_east_1b_prj_rtb_public
  id = "subnet-047baeae858321f71/rtb-0765224565bf16937"
}

import {
  to = aws_instance.Instance
  id = "i-078275ef90bc88675"
}

import {
  to = aws_route_table.prj-rtb-private1-us-east-1a
  id = "rtb-029de9f8107c53070"
}

import {
  to = aws_route_table_association.aws_route_table_association_prj_subnet_private1_us_east_1a_prj_rtb_private1_us_east_1a
  id = "subnet-0e7556fa994ef548d/rtb-029de9f8107c53070"
}

