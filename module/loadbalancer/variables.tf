variable "frontend_tg_name" {
  description = "this is frontend target group name"
  type        = string

}

variable "backend_tg_name" {
  description = "this is backend target group name"
  type        = string

}

variable "vpc_id" {
  description = "this is vpc id for target group"
  type        = string

}

variable "frontend_lb_name" {
  description = "this is frontend load balancer name"
  type        = string

}

variable "security_groups" {
  description = "this is security groups for frontend load balancer"
  type        = list(string)

}


variable "backend_lb_name" {
  description = "this is backend load balancer name"
  type        = string

}

variable "public_subnets" {
  description = "this is load balancer subnets"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listeners"
  type        = string
}

