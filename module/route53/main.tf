# Private Hosted Zone for RDS
resource "aws_route53_zone" "rds_private" {
  name = var.rds_private_zone_name
  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "rds_endpoint" {
  zone_id = aws_route53_zone.rds_private.zone_id
  name    = var.rds_record_name
  type    = "CNAME"
  ttl     = 100
  records = [var.rds_endpoint]
}



# Look up the existing public hosted zone
data "aws_route53_zone" "existing" {
  name         = var.public_zone_name
  private_zone = false
}

# Create a new zone only if the existing zone wasn't found
resource "aws_route53_zone" "public_zone" {
  count = try(data.aws_route53_zone.existing.zone_id, null) == null ? 1 : 0

  name = var.public_zone_name
}

# Select the existing zone or the newly created zone
locals {
  public_zone_id = try(
    data.aws_route53_zone.existing.zone_id,
    aws_route53_zone.public_zone[0].zone_id
  )
}

# Backend DNS record - A Alias to Backend ALB
resource "aws_route53_record" "alb_backend" {
  zone_id = local.public_zone_id
  name    = var.alb_dns_backend_record
  type    = "A"

  alias {
    name                   = var.alb_backend_dns_name
    zone_id                = var.alb_backend_zone_id
    evaluate_target_health = true
  }
}

# Frontend DNS record - A Alias to Frontend ALB
resource "aws_route53_record" "alb_frontend" {
  zone_id = local.public_zone_id
  name    = var.alb_dns_frontend_record
  type    = "A"

  alias {
    name                   = var.alb_front_dns_name
    zone_id                = var.alb_front_zone_id
    evaluate_target_health = true
  }
}