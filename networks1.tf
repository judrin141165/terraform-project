#Create VPC in us-east-1
resource "aws_vpc" "vpc_master" {
  provider             = aws.region-master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "master-vpc-jenkins"
  }

}

#Create VPC in us-west-2
resource "aws_vpc" "vpc_master_oregon" {
  provider             = aws.region-worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "worker-vpc-jenkins"
  }

}

#Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  provider = aws.region-master
  vpc_id   = aws_vpc.vpc_master.id
}

#Create IGW in us-west-2
resource "aws_internet_gateway" "igw-oregon" {
  provider = aws.region-worker
  vpc_id   = aws_vpc.vpc_master_oregon.id
}

#Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state    = "available"
}


#Create subnet # 1 in us-east-1
resource "aws_subnet" "subnet_1" {
  provider          = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"
}


#Create subnet #2  in us-east-1
resource "aws_subnet" "subnet_2" {
  provider          = aws.region-master
  vpc_id            = aws_vpc.vpc_master.id
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  cidr_block        = "10.0.2.0/24"
}


#Create subnet in us-west-2
resource "aws_subnet" "subnet_1_oregon" {
  provider   = aws.region-worker
  vpc_id     = aws_vpc.vpc_master_oregon.id
  cidr_block = "192.168.1.0/24"
}







#initiate peering connection request from us-east-1
resource "aws_vpc_peering_connection" "useast1-uswest2" {
  peer_vpc_id = "aws_vpc.vpc_master_oregon.id"
  vpc_id      = aws_vpc.vpc_master.id
  provider = aws.region-master
  peer_region = "us-west-2"
}
#Accepet vpc peering request in us-west-2 from us-east-1
resource "aws_vpc_peering_connection_accepter" "acceept_peering" {
  vpc_peering_connection_id = "aws_vpc_peering_connection.useast1-uswest2.id"
  provider = aws.region-worker
  auto_accept = [true]
}

#Create Routetable in us-east-1 to IGW
resource "aws_route_table" "internetroute" {
  vpc_id = "aws_vpc.vpc_master.id"
  provider = aws.region-master
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "aws_internet_gateway.igw.id"
  }
  lifecycle {
    ignore_changes = [true]
  }
  tags = "Name=IGW_Routetable_us-east-1"

  }
#Create Routetable in us-east-1 to VPC peering
resource "aws_route_table" "vpc_peering_route" {
  vpc_id = "aws_vpc.vpc_master.id"
  provider = aws.region-master
  route {
    cidr_block = "192.168.1.0/24"
    vpc_peering_connection_id = "aws_vpc_peering_connection.useast1-uswest2.id"
  }
  lifecycle {
    ignore_changes = [true]
  }
  tags = "Name=VPC_Peering_Routetable_us-east-1"
}
#Overwrite default route table of VPC (master) with our route table entries
resource "aws_main_route_table_association" "set-master-default-routetable-assosiation" {
  route_table_id = "aws_route_table.internetroute.id"
  vpc_id         = aws_vpc.vpc_master.id
  provider = aws.region-master

}
#Create Routetable in us-west-2 to IGW
resource "aws_route_table" "internetroute-Oregon" {
  vpc_id = "${aws_vpc.vpc_master_oregon.id}"
  provider = aws.region-worker
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "aws_internet_gateway.igw-oregon.id"
  }
  lifecycle {
    ignore_changes = [true]
  }
  tags = "Name=IGW_Routetable_us-west-2"

  }
#Create Routetable in us-west-2 to VPC peering
resource "aws_route_table" "vpc_peering" {
  vpc_id   = "${aws_vpc.vpc_master_oregon.id}"
  provider = aws.region-worker
  route {
    cidr_block                = "10.0.0.0/16"
    vpc_peering_connection_id = "aws_vpc_peering_connection.useast1-uswest2.id"
  }
  lifecycle {
    ignore_changes = [true]
  }
  tags     = {
    Name = "VPC_Peering_Routetable_us-west-2"
  }
}

#Overwrite default route table of VPC (master) with our route table entries
  resource "aws_main_route_table_association" "set-worker-default-routetable-assosiation" {
    route_table_id = "aws_route_table.internetroute-Oregon.id"
    vpc_id         = "${aws_vpc.vpc_master_oregon.id}"
    provider       = aws.region-worker
  }




