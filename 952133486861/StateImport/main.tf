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

resource "aws_instance" "testy" {
  ami = "ami-037d882b31eae26a2"
  associate_public_ip_address = false
  availability_zone = "us-east-1a"
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  cpu_options {
    core_count = 2
    threads_per_core = 1
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  ebs_optimized = true
  enclave_options {
    enabled = false
  }
  instance_type = "t4g.small"
  maintenance_options {
    auto_recovery = "default"
  }
  metadata_options {
    http_endpoint = "enabled"
    http_protocol_ipv6 = "disabled"
    http_put_response_hop_limit = 2
    http_tokens = "required"
    instance_metadata_tags = "disabled"
  }
  private_dns_name_options {
    enable_resource_name_dns_a_record = false
    enable_resource_name_dns_aaaa_record = false
    hostname_type = "ip-name"
  }
  private_ip = "10.0.129.244"
  region = "us-east-1"
  root_block_device {
    delete_on_termination = true
    encrypted = false
    iops = 3000
    throughput = 125
    volume_size = 8
    volume_type = "gp3"
  }
  subnet_id = "subnet-005f49cb541da34b1"
  tags = {
    Name = "testy"
  }
  tags_all = {
    Name = "testy"
  }
  vpc_security_group_ids = ["sg-00989315b77953ee6"]
}

