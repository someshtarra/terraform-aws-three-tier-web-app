variable "region" {
  description = "this is region for aws"
  type        = string

}

variable "vpc_cidr" {
  description = "this is cidr value for main vpc"
  type        = string
}

variable "public_cidr" {
  description = "this is public subnets cidr and availability zones"
  type = list(object({
    cidr = string
    az   = string
  }))

}

variable "private_cidr" {
  description = "this is private subnets cidr and availability zones"
  type = list(object({
    cidr = string
    az   = string
  }))

}

