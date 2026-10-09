
resource "aws_lb_target_group" "frontend_target_group" {
  name     = var.frontend_tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name = "3-TIER-FRONTEND-TG"
  }

}

resource "aws_lb_target_group" "backend_target_group" {
  name     = var.backend_tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name = "3-TIER-BACKEND-TG"
  }

}

resource "aws_lb" "frontend_lb" {
  name               = var.frontend_lb_name
  load_balancer_type = "application"
  internal           = false
  security_groups    = var.security_groups
  subnets            = var.public_subnets

  tags = {
    Name = var.frontend_lb_name
  }
}

resource "aws_lb" "backend_lb" {
  name               = var.backend_lb_name
  load_balancer_type = "application"
  internal           = false
  security_groups    = var.security_groups
  subnets            = var.public_subnets

  tags = {
    Name = var.backend_lb_name
  }
}

resource "aws_lb_listener" "frontend_lb_listener" {
  load_balancer_arn = aws_lb.frontend_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }

}

resource "aws_lb_listener" "backend_lb_listener" {
  load_balancer_arn = aws_lb.backend_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_target_group.arn
  }

}

resource "aws_lb_listener" "frontend_https_listener" {
  load_balancer_arn = aws_lb.frontend_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }
}

resource "aws_lb_listener" "backend_https_listener" {
  load_balancer_arn = aws_lb.backend_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_target_group.arn
  }
}
