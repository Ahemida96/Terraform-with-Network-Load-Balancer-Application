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

module "public_ec2_module" {
  source = "./modules/ec2_module"

  count              = length(module.vpc_module.public_subnets_id)
  instance_type      = "t2.micro"
  security_group_ids = [module.ec2_security_group_module.sg_id]
  key_name           = aws_key_pair.key_pair.key_name
  subnet_id          = module.vpc_module.public_subnets_id[count.index]
  ami_id             = data.aws_ami.ubuntu.id
  is-public          = true
}

module "private_ec2_module" {
  source = "./modules/ec2_module"

  count              = length(module.vpc_module.private_subnets_id)
  instance_type      = "t2.micro"
  security_group_ids = [module.ec2_security_group_module.sg_id]
  key_name           = aws_key_pair.key_pair.key_name
  subnet_id          = module.vpc_module.private_subnets_id[count.index]
  ami_id             = data.aws_ami.ubuntu.id
}
# -----------------------------Provisioner--------------------------------------------
locals {
  public-instance-ips  = [for instance in module.public_ec2_module : instance.public_ip]
  private-instance-ips = [for instance in module.private_ec2_module : instance.private_ip]
  msg                  = "Instance-IP:"
  file_name            = "all_ips.txt"
}

resource "null_resource" "save_instance_ip" {
  count = length(local.public-instance-ips)
  provisioner "local-exec" {
    command = <<EOT
    echo ${local.msg} ${local.public-instance-ips[count.index]} >> ${local.file_name} 
    echo ${local.msg} ${local.private-instance-ips[count.index]} >> ${local.file_name}
    EOT
  }

}

resource "null_resource" "install-proxy" {
  count = length(local.public-instance-ips)

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.private_key.private_key_pem
    host        = local.public-instance-ips[count.index]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "echo 'server { listen 80; location / { proxy_pass http://${module.private_lb.dns_name}; } }' | sudo tee /etc/nginx/sites-available/default",
      "sudo systemctl restart nginx"
    ]
  }
  depends_on = [null_resource.save_instance_ip]
}

resource "null_resource" "install_apache" {
  count = length(local.private-instance-ips)

  connection {
    type                = "ssh"
    host                = local.private-instance-ips[count.index]
    user                = "ubuntu"
    private_key         = tls_private_key.private_key.private_key_pem
    bastion_host        = module.public_ec2_module[0].public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = tls_private_key.private_key.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install apache2 -y",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2",
      "echo '<h1>Welcome to private instance ${local.private-instance-ips[count.index]}</h1>' | sudo tee /var/www/html/index.html"
    ]
  }
  depends_on = [null_resource.save_instance_ip]
}

# --------------------------------------------------------------------------------

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
  lb_subnets                    = module.vpc_module.private_subnets_id
  lb_type                       = "application"
  lb_security_groups            = [module.ls_security_group_module.sg_id]
  vpc_id                        = module.vpc_module.vpc_id

  lb_target_group_port                    = 80
  lb_target_group_protocol                = "HTTP"
  lb_target_group_type                    = "instance"
  lb_target_group_attachment_instance_ids = module.private_ec2_module[*].instance_id
  lb_target_group_attachment_port         = 80
}

module "public_lb_module" {
  source                        = "./modules/lb_module"
  lb_name                       = "public-lb"
  lb_enable_deletion_protection = false
  lb_internal                   = false
  lb_subnets                    = module.vpc_module.public_subnets_id
  lb_type                       = "application"
  lb_security_groups            = [module.ls_security_group_module.sg_id]

  vpc_id = module.vpc_module.vpc_id

  lb_target_group_port                    = 80
  lb_target_group_protocol                = "HTTP"
  lb_target_group_type                    = "instance"
  lb_target_group_attachment_instance_ids = module.public_ec2_module[*].instance_id
  lb_target_group_attachment_port         = 80
}
