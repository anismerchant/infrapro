resource "aws_key_pair" "ssh" {
  key_name   = "infrapro-key"
  public_key = file(var.ssh_public_key_path)

  lifecycle {
    prevent_destroy = true
  }
}


data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "sandbox" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.ssh.key_name

  tags = {
    Name = "infrapro-sandbox"
  }
}
