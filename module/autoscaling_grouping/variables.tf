variable "frontend_asg_name" {
  description = "this is frontend autoscaling group name"
  type        = string

}

variable "backend_asg_name" {
  description = "this is backend autoscaling group name"
  type        = string

}

variable "frontend_min_size" {
  description = "this is frontend min size for autoscaling group"
  type        = number

}

variable "frontend_max_size" {
  description = "this is frontend max size for autoscaling group"
  type        = number

}

variable "frontend_desired_capacity" {
  description = "this is frontend desired capacity for autoscaling group"
  type        = number

}


variable "backend_min_size" {
  description = "this is backend min size for autoscaling group"
  type        = number

}

variable "backend_max_size" {
  description = "this is backend max size for autoscaling group"
  type        = number

}

variable "backend_desired_capacity" {
  description = "this is backend desired capacity for autoscaling group"
  type        = number

}

variable "frontend_asg_subnets" {
  description = "this is autoscaling group subnets for frontend"
  type        = list(string)

}

variable "backend_asg_subnets" {
  description = "this is autoscaling group subnets for backend"
  type        = list(string)

}

variable "frontend_target_group_arns" {
  description = "this is frontend autoscaling group target group arn"
  type        = list(string)

}
variable "backend_target_group_arns" {
  description = "this is backend autoscaling group target group arn"
  type        = list(string)

}

variable "frontend_asg_lt" {
  description = "this is frontend autoscaling group lanuch template"
  type        = string

}

variable "backend_asg_lt" {
  description = "this is backend autoscaling group lanuch template"
  type        = string

}