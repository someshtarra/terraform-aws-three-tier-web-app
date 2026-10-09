output "frontend_lb_id" {
  value = aws_lb.frontend_lb.id

}

output "frontend_lb_dns" {
  value = aws_lb.frontend_lb.dns_name

}

output "backend_lb_id" {
  value = aws_lb.backend_lb.id

}

output "backend_lb_dns" {
  value = aws_lb.backend_lb.dns_name

}

output "frontend_target_group_arns" {
  value = aws_lb_target_group.frontend_target_group.arn
}

output "backend_target_group_arns" {
  value = aws_lb_target_group.backend_target_group.arn
}

output "frontend_lb_zone_id" {
  value = aws_lb.frontend_lb.zone_id
}

output "backend_lb_zone_id" {
  value = aws_lb.backend_lb.zone_id
}