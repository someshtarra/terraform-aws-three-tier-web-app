resource "aws_autoscaling_group" "frontend_asg" {
  name                = var.frontend_asg_name
  min_size            = var.frontend_min_size
  max_size            = var.frontend_max_size
  desired_capacity    = var.frontend_desired_capacity
  vpc_zone_identifier = var.frontend_asg_subnets
  target_group_arns   = var.frontend_target_group_arns
  launch_template {
    id      = var.frontend_asg_lt
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  name                = var.backend_asg_name
  min_size            = var.backend_min_size
  max_size            = var.backend_max_size
  desired_capacity    = var.backend_desired_capacity
  vpc_zone_identifier = var.backend_asg_subnets
  target_group_arns   = var.backend_target_group_arns
  launch_template {
    id      = var.backend_asg_lt
    version = "$Latest"
  }
}