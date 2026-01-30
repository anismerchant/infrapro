# Input variables will be defined here

variable "aws_region" {
  type    = string
  description = "AWS region to deploy resources into"
  default = "us-east-2"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to the local SSH public key used for EC2 access"
  default     = "~/.ssh/infrapro-key.pub"
}
