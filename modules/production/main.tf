resource "aws_security_group" "public_sg" {
  name        = "public_sg"

  vpc_id      = var.vpc_id

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
    cidr_blocks = ["0.0.0.0/0"] 
  
  }

  tags = {
    Name = "bastion-sg"
  }
}


resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  vpc_id      = var.vpc_id

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

  tags = {
    Name = "private-ec2-sg"
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-0261755bbcb8c4a84"
  instance_type               = "t3.micro"
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
}


resource "aws_instance" "ec2" {
  ami                    = "ami-0261755bbcb8c4a84"
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = {
    Name = "private-ec2"
  }
}


