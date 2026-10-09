resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_groups
  subnet_id              = var.public_sn

  tags = {
    Name = "Bastion-Host"
  }

}