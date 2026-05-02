output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
}

output "ec2_private_ip" {
  value       = aws_instance.ec2.private_ip
}

output "bastion_instance_id" {
  value       = aws_instance.bastion.id
}

output "ec2_instance_id" {
  value       = aws_instance.ec2.id
}