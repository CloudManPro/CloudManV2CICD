terraform {
	required_providers {
		aws = {
		source = "hashicorp/aws"
		}
	}
	backend "s3" {
		bucket = "cloudan-v2-cicd"
		key    = "952133486861/StateImport/main.tfstate"
		region = "us-east-1"
	}
	}

	provider "aws" {
	region = "us-east-1"
	}

	resource "aws_internet_gateway" "project-igw" {
  tags {
    Name = "project-igw"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

resource "aws_route" "project-rtb-public_rtb_0696e55dfe97754cf_0_0_0_0_0" {
  carrier_gateway_id = ""
  core_network_arn = ""
  destination_cidr_block = "0.0.0.0/0"
  destination_ipv6_cidr_block = ""
  destination_prefix_list_id = ""
  egress_only_gateway_id = ""
  gateway_id = "igw-0df108f2d8c806e33"
  id = "r-rtb-0696e55dfe97754cf1080289494"
  local_gateway_id = ""
  nat_gateway_id = ""
  network_interface_id = ""
  region = "us-east-1"
  route_table_id = "rtb-0696e55dfe97754cf"
  transit_gateway_id = ""
  vpc_endpoint_id = ""
  vpc_peering_connection_id = ""
}

resource "aws_route_table" "project-rtb-public" {
  propagating_vgws = []
  route {
    carrier_gateway_id = ""
    cidr_block = "0.0.0.0/0"
    core_network_arn = ""
    destination_prefix_list_id = ""
    egress_only_gateway_id = ""
    gateway_id = "igw-0df108f2d8c806e33"
    ipv6_cidr_block = ""
    local_gateway_id = ""
    nat_gateway_id = ""
    network_interface_id = ""
    transit_gateway_id = ""
    vpc_endpoint_id = ""
    vpc_peering_connection_id = ""
  }
  tags {
    Name = "project-rtb-public"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

resource "aws_route_table_association" "project-rtb-public_subnet_049cfff09522aa1e8_rtb_0696e55dfe97754cf" {
  gateway_id = ""
  id = "rtbassoc-02c69bc77f408f4f9"
  region = "us-east-1"
  route_table_id = "rtb-0696e55dfe97754cf"
  subnet_id = "subnet-049cfff09522aa1e8"
}

resource "aws_route_table_association" "project-rtb-public_subnet_0c41cdce4a4ecdd3a_rtb_0696e55dfe97754cf" {
  gateway_id = ""
  id = "rtbassoc-0020b235d6503baa2"
  region = "us-east-1"
  route_table_id = "rtb-0696e55dfe97754cf"
  subnet_id = "subnet-0c41cdce4a4ecdd3a"
}

resource "aws_subnet" "project-subnet-private1-us-east-1a" {
  assign_ipv6_address_on_creation = false
  availability_zone = "us-east-1a"
  cidr_block = "192.168.8.0/24"
  customer_owned_ipv4_pool = ""
  enable_dns64 = false
  enable_resource_name_dns_a_record_on_launch = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv6_cidr_block = ""
  ipv6_native = false
  map_customer_owned_ip_on_launch = false
  map_public_ip_on_launch = false
  outpost_arn = ""
  private_dns_hostname_type_on_launch = "ip-name"
  tags {
    Name = "project-subnet-private1-us-east-1a"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

resource "aws_subnet" "project-subnet-private2-us-east-1b" {
  assign_ipv6_address_on_creation = false
  availability_zone = "us-east-1b"
  cidr_block = "192.168.9.0/24"
  customer_owned_ipv4_pool = ""
  enable_dns64 = false
  enable_resource_name_dns_a_record_on_launch = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv6_cidr_block = ""
  ipv6_native = false
  map_customer_owned_ip_on_launch = false
  map_public_ip_on_launch = false
  outpost_arn = ""
  private_dns_hostname_type_on_launch = "ip-name"
  tags {
    Name = "project-subnet-private2-us-east-1b"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

resource "aws_subnet" "project-subnet-public1-us-east-1a" {
  assign_ipv6_address_on_creation = false
  availability_zone = "us-east-1a"
  cidr_block = "192.168.0.0/24"
  customer_owned_ipv4_pool = ""
  enable_dns64 = false
  enable_resource_name_dns_a_record_on_launch = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv6_cidr_block = ""
  ipv6_native = false
  map_customer_owned_ip_on_launch = false
  map_public_ip_on_launch = false
  outpost_arn = ""
  private_dns_hostname_type_on_launch = "ip-name"
  tags {
    Name = "project-subnet-public1-us-east-1a"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

resource "aws_subnet" "project-subnet-public2-us-east-1b" {
  assign_ipv6_address_on_creation = false
  availability_zone = "us-east-1b"
  cidr_block = "192.168.1.0/24"
  customer_owned_ipv4_pool = ""
  enable_dns64 = false
  enable_resource_name_dns_a_record_on_launch = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv6_cidr_block = ""
  ipv6_native = false
  map_customer_owned_ip_on_launch = false
  map_public_ip_on_launch = false
  outpost_arn = ""
  private_dns_hostname_type_on_launch = "ip-name"
  tags {
    Name = "project-subnet-public2-us-east-1b"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

resource "aws_vpc" "project-vpc" {
  assign_generated_ipv6_cidr_block = false
  cidr_block = "192.168.0.0/20"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_network_address_usage_metrics = false
  instance_tenancy = "default"
  ipv6_cidr_block = ""
  ipv6_cidr_block_network_border_group = ""
  ipv6_ipam_pool_id = ""
  ipv6_netmask_length = 0
  tags {
    Name = "project-vpc"
  }
}

