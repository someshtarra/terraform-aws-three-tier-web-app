variable "ami_id" {
  description = "this is ami id for instance"
  type        = string

}

variable "instance_type" {
  description = "this is instance type for bastion host"
  type        = string

}

variable "key_name" {
  description = "this is key pair name"
  type        = string

}

variable "security_groups" {
  description = "this is security group ids"
  type        = list(string)

}

variable "public_sn" {
  description = "this is public subnet id for instance"
  type        = string

}