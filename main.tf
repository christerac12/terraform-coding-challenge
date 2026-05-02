# Assume you have Admin Access on the AWS Account

resource "tls_private_key" "kp" {
  algorithm = "RSA"
}

resource "local_file" "kp_private" {
  content         = tls_private_key.kp.private_key_pem
  filename        = "${path.module}/kp.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "kp_public" {
  key_name   = "terraform-kp"
  public_key = tls_private_key.kp.public_key_openssh
}
