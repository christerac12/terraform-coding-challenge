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
