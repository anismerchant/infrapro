output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "ssh_sg_id" {
  value = aws_security_group.ssh.id
}
