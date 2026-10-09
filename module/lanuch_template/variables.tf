variable "frontend_LT_name" {
  description = "this is frontend lanuch template name"
  type        = string

}

variable "key_name" {
  description = "this is lanuch template key pair name"
  type        = string

}
variable "instance_type" {
  description = "this is lanuch template instance type"
  type        = string

}

variable "frontend_image_id" {
  description = "this is frontend lanch template image id"
  type        = string

}

variable "security_group_id" {
  description = "this is lanch template security group id"
  type        = list(string)

}

variable "backend_LT_name" {
  description = "this is backend lanuch template name"
  type        = string

}

variable "backend_image_id" {
  description = "this is backend lanch template image id"
  type        = string

}

variable "frontend_user_data" {
  description = "this is user data for frontend"
  type        = string

}

variable "backend_user_data" {
  description = "this is user data for backend"
  type        = string

}