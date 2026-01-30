# Output values will be defined here

output "sandbox_public_ip" {
  description = "Public IP of the sandbox EC2 instance"
  value       = module.compute.sandbox_public_ip
}
