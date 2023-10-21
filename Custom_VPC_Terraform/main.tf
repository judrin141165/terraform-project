
#this template is used for setting up custom VPC Module with db instance and ec2 instance



terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.0"
    }
  }

  required_version = ">= 0.15.0"

}

provider "aws" {
  region = "us-east-2"
}

variable "name" {
  type = string
  default = "terraform_template"
  validation {
    condition = length(var.name) > 3
    error_message = "The name must be minimum  4 characters."
  }
}

variable "Description" {
  type = string
  default = "custom-vpc-with-ec2-instance and db-instance"
}
variable "availability_zone" {
  type = list(object({
    AZ1=string
    AZ2=string
    AZ3=string
  }))
  default = [
    {
      AZ1="us-east-2a"
      AZ2="us-east-2b"
      AZ3="us-east-2c"

    }]
}
variable "region" {
  type = string
  default = "us-east-2"
}
#variable "dbs_security_group_id" {}
#data "aws_security_group" "DBS_security_group" {
  #id = var.dbs_security_group_id
#}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "my-vpc"

  cidr               = "10.0.0.0/16"
  azs                = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets    = ["10.0.1.0/24"]
  public_subnets     = ["10.0.101.0/24","10.0.102.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = true
  create_igw         = true
  single_nat_gateway = true

  create_database_nat_gateway_route  = true
  create_database_subnet_group       = true
  create_database_subnet_route_table = true
  private_dedicated_network_acl      = true
  private_acl_tags                   = {}
  private_inbound_acl_rules          = []
  private_outbound_acl_rules         = []
  private_subnet_suffix              = "private"
  private_subnet_tags                = {}


  enable_dns_support = true

  public_dedicated_network_acl = true
  public_inbound_acl_rules     = []
  public_outbound_acl_rules    = []
  public_route_table_tags      = {}
  public_subnet_suffix         = "public"
  public_subnet_tags           = {}


}


output "vpc_arn" {
  value = "vpc_arn"


}
resource "aws_security_group" "DBS_security_group" {
name = "dbs_security_group"
  description = "name_of_dbs_security_group"

  ingress {
    from_port = 3306
    protocol  = "tcp"
    to_port   = 3306
    cidr_blocks = ["10.0.0.0/16"]


  }
}
resource "aws_security_group" "webserver_security_group" {
  name = "webserver_security_Group"


  ingress {
    from_port = 443
    protocol  = "tcp"
    to_port   = 443


    cidr_blocks = ["10.0.0.0/16"]


  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    protocol    = "tcp"
    to_port     = 0
    cidr_blocks = ["10.0.0.0/16"]

  }
}
resource "aws_db_instance" "db" {
  instance_class            = "db.t3.micro"
  allocated_storage         = 10
  engine                    = "mysql"
  engine_version            = "5.7"

  username                  = "admin"
  password                  = "password"
  skip_final_snapshot       = true
  availability_zone = "us-east-2a"
  vpc_security_group_ids = [aws_security_group.DBS_security_group.id]


  #  security_group_names = aws_security_group.DBS_security_group
}
output "db_instance" {
  value = aws_db_instance.db
  depends_on = [aws_security_group.DBS_security_group]
  sensitive = true

}


module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type          = "t2.micro"
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.webserver_security_group.id]

  subnet_id              = "subnet-eddcdzz4"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

























