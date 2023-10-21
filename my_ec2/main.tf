terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}




resource "aws_instance" "server" {
  provider = aws.east-1
  ami           = "ami-026ebd4cfe2c043b2"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleServerInstance"
  }


}
resource "aws_instance" "ec2_remote" {
  provider = aws.west-2
  ami = "ami-00aa0673b34e3c150"
  instance_type = "t2.micro"

  tags = {
    Name="ec2_remote"
  }
}