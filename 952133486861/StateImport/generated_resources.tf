# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "rtb-0d5c508a116780221"
resource "aws_route_table" "project-rtb-private1-us-east-1a" {
  propagating_vgws = []
  region           = "us-east-1"
  route            = []
  tags = {
    Name = "project-rtb-private1-us-east-1a"
  }
  tags_all = {
    Name = "project-rtb-private1-us-east-1a"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

# __generated__ by Terraform from "rtb-03e66a9c5ae98a21b"
resource "aws_route_table" "project-rtb-private2-us-east-1b" {
  propagating_vgws = []
  region           = "us-east-1"
  route            = []
  tags = {
    Name = "project-rtb-private2-us-east-1b"
  }
  tags_all = {
    Name = "project-rtb-private2-us-east-1b"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

# __generated__ by Terraform from "rtb-0696e55dfe97754cf_0.0.0.0/0"
resource "aws_route" "project-rtb-public_rtb_0696e55dfe97754cf_0_0_0_0_0" {
  carrier_gateway_id          = null
  core_network_arn            = null
  destination_cidr_block      = "0.0.0.0/0"
  destination_ipv6_cidr_block = null
  destination_prefix_list_id  = null
  egress_only_gateway_id      = null
  gateway_id                  = "igw-0df108f2d8c806e33"
  local_gateway_id            = null
  nat_gateway_id              = null
  network_interface_id        = null
  region                      = "us-east-1"
  route_table_id              = "rtb-0696e55dfe97754cf"
  transit_gateway_id          = null
  vpc_endpoint_id             = null
  vpc_peering_connection_id   = null
}

# __generated__ by Terraform from "igw-0df108f2d8c806e33"
resource "aws_internet_gateway" "project-igw" {
  region = "us-east-1"
  tags = {
    Name = "project-igw"
  }
  tags_all = {
    Name = "project-igw"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

# __generated__ by Terraform
resource "aws_subnet" "project-subnet-public1-us-east-1a" {
  assign_ipv6_address_on_creation                = false
  availability_zone                              = "us-east-1a"
  availability_zone_id                           = "use1-az4"
  cidr_block                                     = "192.168.0.0/24"
  customer_owned_ipv4_pool                       = null
  enable_dns64                                   = false
  enable_lni_at_device_index                     = 0
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv4_ipam_pool_id                              = null
  ipv4_netmask_length                            = null
  ipv6_cidr_block                                = null
  ipv6_ipam_pool_id                              = null
  ipv6_native                                    = false
  ipv6_netmask_length                            = null
  map_customer_owned_ip_on_launch                = false
  map_public_ip_on_launch                        = false
  outpost_arn                                    = null
  private_dns_hostname_type_on_launch            = "ip-name"
  region                                         = "us-east-1"
  tags = {
    Name = "project-subnet-public1-us-east-1a"
  }
  tags_all = {
    Name = "project-subnet-public1-us-east-1a"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

# __generated__ by Terraform
resource "aws_subnet" "project-subnet-public2-us-east-1b" {
  assign_ipv6_address_on_creation                = false
  availability_zone                              = "us-east-1b"
  availability_zone_id                           = "use1-az6"
  cidr_block                                     = "192.168.1.0/24"
  customer_owned_ipv4_pool                       = null
  enable_dns64                                   = false
  enable_lni_at_device_index                     = 0
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv4_ipam_pool_id                              = null
  ipv4_netmask_length                            = null
  ipv6_cidr_block                                = null
  ipv6_ipam_pool_id                              = null
  ipv6_native                                    = false
  ipv6_netmask_length                            = null
  map_customer_owned_ip_on_launch                = false
  map_public_ip_on_launch                        = false
  outpost_arn                                    = null
  private_dns_hostname_type_on_launch            = "ip-name"
  region                                         = "us-east-1"
  tags = {
    Name = "project-subnet-public2-us-east-1b"
  }
  tags_all = {
    Name = "project-subnet-public2-us-east-1b"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

# __generated__ by Terraform
resource "aws_route_table" "project-rtb-public" {
  propagating_vgws = []
  region           = "us-east-1"
  route = [{
    carrier_gateway_id         = ""
    cidr_block                 = "0.0.0.0/0"
    core_network_arn           = ""
    destination_prefix_list_id = ""
    egress_only_gateway_id     = ""
    gateway_id                 = "igw-0df108f2d8c806e33"
    ipv6_cidr_block            = ""
    local_gateway_id           = ""
    nat_gateway_id             = ""
    network_interface_id       = ""
    transit_gateway_id         = ""
    vpc_endpoint_id            = ""
    vpc_peering_connection_id  = ""
  }]
  tags = {
    Name = "project-rtb-public"
  }
  tags_all = {
    Name = "project-rtb-public"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

# __generated__ by Terraform from "subnet-049cfff09522aa1e8/rtb-0696e55dfe97754cf"
resource "aws_route_table_association" "project-rtb-public_subnet_049cfff09522aa1e8_rtb_0696e55dfe97754cf" {
  gateway_id     = null
  region         = "us-east-1"
  route_table_id = "rtb-0696e55dfe97754cf"
  subnet_id      = "subnet-049cfff09522aa1e8"
}

# __generated__ by Terraform from "subnet-0c41cdce4a4ecdd3a/rtb-0696e55dfe97754cf"
resource "aws_route_table_association" "project-rtb-public_subnet_0c41cdce4a4ecdd3a_rtb_0696e55dfe97754cf" {
  gateway_id     = null
  region         = "us-east-1"
  route_table_id = "rtb-0696e55dfe97754cf"
  subnet_id      = "subnet-0c41cdce4a4ecdd3a"
}

# __generated__ by Terraform from "subnet-0e49f7d42b6759b2b/rtb-0d5c508a116780221"
resource "aws_route_table_association" "project-rtb-private1-us-east-1a_subnet_0e49f7d42b6759b2b_rtb_0d5c508a116780221" {
  gateway_id     = null
  region         = "us-east-1"
  route_table_id = "rtb-0d5c508a116780221"
  subnet_id      = "subnet-0e49f7d42b6759b2b"
}

# __generated__ by Terraform from "subnet-08c60b7ddb33a0e47/rtb-03e66a9c5ae98a21b"
resource "aws_route_table_association" "project-rtb-private2-us-east-1b_subnet_08c60b7ddb33a0e47_rtb_03e66a9c5ae98a21b" {
  gateway_id     = null
  region         = "us-east-1"
  route_table_id = "rtb-03e66a9c5ae98a21b"
  subnet_id      = "subnet-08c60b7ddb33a0e47"
}

# __generated__ by Terraform
resource "aws_subnet" "project-subnet-private1-us-east-1a" {
  assign_ipv6_address_on_creation                = false
  availability_zone                              = "us-east-1a"
  availability_zone_id                           = "use1-az4"
  cidr_block                                     = "192.168.8.0/24"
  customer_owned_ipv4_pool                       = null
  enable_dns64                                   = false
  enable_lni_at_device_index                     = 0
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv4_ipam_pool_id                              = null
  ipv4_netmask_length                            = null
  ipv6_cidr_block                                = null
  ipv6_ipam_pool_id                              = null
  ipv6_native                                    = false
  ipv6_netmask_length                            = null
  map_customer_owned_ip_on_launch                = false
  map_public_ip_on_launch                        = false
  outpost_arn                                    = null
  private_dns_hostname_type_on_launch            = "ip-name"
  region                                         = "us-east-1"
  tags = {
    Name = "project-subnet-private1-us-east-1a"
  }
  tags_all = {
    Name = "project-subnet-private1-us-east-1a"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

# __generated__ by Terraform
resource "aws_subnet" "project-subnet-private2-us-east-1b" {
  assign_ipv6_address_on_creation                = false
  availability_zone                              = "us-east-1b"
  availability_zone_id                           = "use1-az6"
  cidr_block                                     = "192.168.9.0/24"
  customer_owned_ipv4_pool                       = null
  enable_dns64                                   = false
  enable_lni_at_device_index                     = 0
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv4_ipam_pool_id                              = null
  ipv4_netmask_length                            = null
  ipv6_cidr_block                                = null
  ipv6_ipam_pool_id                              = null
  ipv6_native                                    = false
  ipv6_netmask_length                            = null
  map_customer_owned_ip_on_launch                = false
  map_public_ip_on_launch                        = false
  outpost_arn                                    = null
  private_dns_hostname_type_on_launch            = "ip-name"
  region                                         = "us-east-1"
  tags = {
    Name = "project-subnet-private2-us-east-1b"
  }
  tags_all = {
    Name = "project-subnet-private2-us-east-1b"
  }
  vpc_id = "vpc-0b61653f5fbcdc5fb"
}

# __generated__ by Terraform
resource "aws_vpc" "project-vpc" {
  assign_generated_ipv6_cidr_block     = false
  cidr_block                           = "192.168.0.0/20"
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  enable_network_address_usage_metrics = false
  instance_tenancy                     = "default"
  ipv4_ipam_pool_id                    = null
  ipv4_netmask_length                  = null
  ipv6_cidr_block                      = null
  ipv6_cidr_block_network_border_group = null
  ipv6_ipam_pool_id                    = null
  ipv6_netmask_length                  = 0
  region                               = "us-east-1"
  tags = {
    Name = "project-vpc"
  }
  tags_all = {
    Name = "project-vpc"
  }
}
