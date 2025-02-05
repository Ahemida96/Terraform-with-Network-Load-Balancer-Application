module "vpc_module" {
  source               = "./modules/vpc_module"
  vpc_name             = "main-vpc"
  vpc_cidr_block       = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  public_subnets       = ["10.0.1.0/24", "10.0.3.0/24"]
  public_subnet_names  = ["public-subnet-1", "public-subnet-2"]
  private_subnets      = ["10.0.2.0/24", "10.0.4.0/24"]
  private_subnet_names = ["private-subnet-1", "private-subnet-2"]
  availability_zones   = ["us-east-1a", "us-east-1b"]

}

module "ec2_security_group_module" {
  source              = "./modules/security_group_module"
  security_group_name = "ec2-sg"
  vpc_id              = module.vpc_module.vpc_id
}

module "ec2_module" {
  source = "./modules/ec2_module"

  count              = length(module.vpc_module.all_subnets_id)
  instance_type      = "t2.micro"
  security_group_ids = [module.ec2_security_group_module.sg_id]
  key_name           = aws_key_pair.key_pair.key_name
  subnet_id          = module.vpc_module.all_subnets_id[count.index]
  ami_id             = data.aws_ami.amazon_linux.id
}


module "ls_security_group_module" {
  source              = "./modules/security_group_module"
  security_group_name = "ls-sg"
  vpc_id              = module.vpc_module.vpc_id
  inbound_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  outbound_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

module "private_lb" {
  source                        = "./modules/lb_module"
  lb_name                       = "private-lb"
  lb_enable_deletion_protection = false
  lb_internal                   = true
  lb_subnets                    = module.vpc_module.all_subnets_id
  lb_type                       = "network"
  lb_security_groups            = [module.ls_security_group_module.sg_id]
  vpc_id                        = module.vpc_module.vpc_id

  lb_target_group_port                    = 80
  lb_target_group_protocol                = "HTTP"
  lb_target_group_type                    = "instance"
  lb_target_group_attachment_instance_ids = module.ec2_module[*].id
  lb_target_group_attachment_port         = 80
}

locals {
  public_subnets_id = [for subnet in module.vpc_module.public_subnets_id : subnet]
}

module "public_lb_module" {
  source                        = "./modules/lb_module"
  lb_name                       = "public-lb"
  lb_enable_deletion_protection = false
  lb_internal                   = false
  lb_subnets                    = local.public_subnets_id
  lb_type                       = "network"
  lb_security_groups            = [module.ls_security_group_module.sg_id]

  vpc_id = module.vpc_module.vpc_id

  lb_target_group_port                    = 80
  lb_target_group_protocol                = "HTTP"
  lb_target_group_type                    = "instance"
  lb_target_group_attachment_instance_ids = local.public_subnets_id
  lb_target_group_attachment_port         = 80
}
