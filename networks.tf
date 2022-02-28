terraform {
  required_providers {
    aws= {
      source="hashicorp/aws"
      version = "~> 3.27"
    }

  }
  required_version = ">= 0.14.9"
}





#create VPC in us-east-1
resource "aws_vpc" "vpc_master" {
  cidr_block           = "10.0.0.0/16"
  provider             = aws
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags                 = {
    Name = "master-vpc-jenkins"
  }
}
  #create VPC in us-west-2
resource "aws_vpc" "vpc_master_oregon" {
  cidr_block           = "192.168.0.0/16"
  provider             = aws
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = {
    Name = "worker-vpc-jenkins"
  }
}
#create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  provider = aws
  vpc_id   = "${aws_vpc.vpc_master.id}"
}

#create IGW in us-west-2
resource "aws_internet_gateway" "igw-oregon" {
  provider = aws
  vpc_id = "${aws_vpc.vpc_master_oregon.id}"
}
# get all available AZ in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws
  state = "available"
}

#create subnet1 #1 in us-east-1
resource "aws_subnet" "sub-net1" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = "${aws_vpc.vpc_master.id}"
  provider = aws
  availability_zone = element(data.aws_availability_zones.azs.names,0)
}

#create subnet2 #2 in us-east1
resource "aws_subnet" "sub-net2" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = "${aws_vpc.vpc_master.id}"
  provider = aws
  availability_zone = element(data.aws_availability_zones.azs.names,1)
}

#create subnet in us-west-2
resource "aws_subnet" "subnet_1_oregon" {
  cidr_block = "192.168.1.0/24"
  vpc_id     = "${aws_vpc.vpc_master_oregon.id}"
  provider = aws
}