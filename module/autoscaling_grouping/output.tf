output "frontend_asg_id" {
  value = aws_autoscaling_group.frontend_asg.id

}

output "backend_asg_id" {
  value = aws_autoscaling_group.backend_asg.id

}