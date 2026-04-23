# Assume you have Admin Access on the AWS Account

terraform {

  backend "local" {
    path = "./terraform.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.22.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

provider "tls" {}


resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.private_subnet.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "public_sg" {
  name   = "public_sg"
  vpc_id = aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # replace with your ip
  }
}

resource "aws_security_group" "private_sg" {
  name   = "private_sg"
  vpc_id = aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }
}

resource "tls_private_key" "kp" {
  algorithm = "RSA"
}

resource "local_file" "kp_private" {
  content  = tls_private_key.kp.private_key_pem
  filename = "./kp.pem"
}

resource "aws_key_pair" "kp_public" {
  key_name   = "kp.pem"
  public_key = tls_private_key.kp.public_key_openssh
}

resource "aws_instance" "ec2" {
  ami             = "ami-0efcece6bed30fd98"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.kp_public.key_name
  security_groups = [aws_security_group.private_sg.id]
  subnet_id       = aws_subnet.private_subnet.id
}

resource "aws_instance" "bastion" {
  ami                         = "ami-0efcece6bed30fd98"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.kp_public.key_name
  security_groups             = [aws_security_group.public_sg.id]
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true

}

# scp keypair file to bastion and ssh into ec2.
