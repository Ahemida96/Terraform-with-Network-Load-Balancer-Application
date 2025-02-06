resource "aws_instance" "this" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = var.subnet_id
  security_groups = var.security_group_ids
  user_data       = var.user_data
  tags            = var.tags

  # transfer the private key to the instance
  provisioner "file" {
    source      = "./terraform-key.pem"
    destination = "/home/ec2-user/terraform-key.pem"
  }
}
