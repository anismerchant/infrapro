# Output values will be defined here

output "sandbox_public_ip" {
  description = "Public IP of the sandbox EC2 instance"
  value       = aws_instance.sandbox.public_ip
}
