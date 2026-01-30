variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the instance"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the local SSH public key used for EC2 access"
  type        = string
}