terraform {
  backend "s3" {
    bucket = "cloudan-v2-cicd"
    key    = "952133486861/StateImport/main.tfstate"
    region = "us-east-1"
  }
}

import {
  to = aws_vpc.prj-vpc
  id = "vpc-0931926afa7488760"
}

import {
  to = aws_subnet.prj-subnet-private1-us-east-1a
  id = "subnet-0700fd2cb99b5c9b8"
}

import {
  to = aws_subnet.prj-subnet-private2-us-east-1b
  id = "subnet-0176fefeeed75d7f5"
}

import {
  to = aws_internet_gateway.prj-igw
  id = "igw-01a5cd2e6fcdae7ba"
}

import {
  to = aws_subnet.prj-subnet-public2-us-east-1b
  id = "subnet-02042bee71db89c81"
}

import {
  to = aws_subnet.prj-subnet-public1-us-east-1a
  id = "subnet-02952a1b32c034dd2"
}

import {
  to = aws_route_table.prj-rtb-private1-us-east-1a
  id = "rtb-04d87a9569beb1880"
}

import {
  to = aws_route_table_association.prj-rtb-private1-us-east-1a_subnet_0700fd2cb99b5c9b8_rtb_04d87a9569beb1880
  id = "subnet-0700fd2cb99b5c9b8/rtb-04d87a9569beb1880"
}

import {
  to = aws_route_table.prj-rtb-public
  id = "rtb-083c0136e4564dea5"
}

import {
  to = aws_route.prj-rtb-public_rtb_083c0136e4564dea5_0_0_0_0_0
  id = "rtb-083c0136e4564dea5_0.0.0.0/0"
}

import {
  to = aws_route_table_association.prj-rtb-public_subnet_02042bee71db89c81_rtb_083c0136e4564dea5
  id = "subnet-02042bee71db89c81/rtb-083c0136e4564dea5"
}

import {
  to = aws_route_table_association.prj-rtb-public_subnet_02952a1b32c034dd2_rtb_083c0136e4564dea5
  id = "subnet-02952a1b32c034dd2/rtb-083c0136e4564dea5"
}

import {
  to = aws_route_table.prj-rtb-private2-us-east-1b
  id = "rtb-00390fd114c1c6a2f"
}

import {
  to = aws_route_table_association.prj-rtb-private2-us-east-1b_subnet_0176fefeeed75d7f5_rtb_00390fd114c1c6a2f
  id = "subnet-0176fefeeed75d7f5/rtb-00390fd114c1c6a2f"
}

