
#this template is used for setting up custom VPC Module



terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }

  required_version = ">= 0.12.0"

}

provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name= "my-vpc"

  cidr= "10.0.0.0/16"
  azs= ["us-east-2a","us-east-2b","us-east-2c"]
  private_subnets= ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  public_subnets= ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]
  enable_nat_gateway=true
  enable_vpn_gateway=true
  create_igw=true
  single_nat_gateway=true

  create_database_nat_gateway_route=true
  create_database_subnet_group=true
  create_database_subnet_route_table=true
  private_dedicated_network_acl=true
  private_acl_tags={}
  private_inbound_acl_rules=[]
  private_outbound_acl_rules=[]
  private_subnet_suffix="private"
  private_subnet_tags={}


  enable_dns_support=true

  public_dedicated_network_acl=true
  public_inbound_acl_rules=[]
  public_outbound_acl_rules=[]
  public_route_table_tags={}
  public_subnet_suffix="public"
  public_subnet_tags={}





}


