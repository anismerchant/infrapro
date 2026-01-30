provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"
  aws_region = var.aws_region
}

module "compute" {
  source              = "./modules/compute"
  subnet_id           = module.network.public_subnet_id
  security_group_id   = module.network.ssh_sg_id
  ssh_public_key_path = var.ssh_public_key_path
}
