resource "aws_launch_template" "frontend_lanuch_template" {
  name          = var.frontend_LT_name
  key_name      = var.key_name
  image_id      = var.frontend_image_id
  instance_type = var.instance_type
  user_data     = base64encode(file("${path.module}/${var.frontend_user_data}"))

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_group_id
  }

  tags = {
    Name = var.frontend_LT_name
  }

}


resource "aws_launch_template" "backend_lanuch_template" {
  name          = var.backend_LT_name
  key_name      = var.key_name
  image_id      = var.backend_image_id
  instance_type = var.instance_type
  user_data     = base64encode(file("${path.module}/${var.backend_user_data}"))

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_group_id
  }

  tags = {
    Name = var.backend_LT_name
  }

}