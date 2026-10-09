variable "sg_name" {
  description = "this is security group name for 3 tier"
  type        = string

}

variable "vpc_id" {
  description = "this is vpc id for security group"
  type        = string

}

variable "ingress_from_port" {
  description = "this is ingress from port number"
  type        = number

}

variable "ingress_to_port" {
  description = "this is ingress to port number"
  type        = number

}

variable "ingress_protocol" {
  description = "this is ingress protocol"
  type        = string

}

variable "ingress_cidr_blocks" {
  description = "this is ingress cidr blocks"
  type        = list(string)

}

variable "egress_from_port" {
  description = "this is egress from port number"
  type        = number

}

variable "egress_to_port" {
  description = "this is egress to port number"
  type        = number

}

variable "egress_protocol" {
  description = "this is egress protocol"
  type        = string

}

variable "egress_cidr_blocks" {
  description = "this is egress cidr blocks"
  type        = list(string)

}