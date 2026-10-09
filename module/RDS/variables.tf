variable "db_subnet_group_name" {
  description = "this is database subnet group name"
  type        = string

}

variable "db_subnets" {
  description = "this is database subnets group"
  type        = list(string)

}

variable "db_identifier" {
  description = "this is database identifier"
  type        = string

}

variable "db_engine" {
  description = "this is database engine"
  type        = string

}

variable "db_storage" {
  description = "this is database storage"
  type        = number

}

variable "db_storage_type" {
  description = "this is database storage type"
  type        = string
}

variable "db_instance_class" {
  description = "this is database instance class"
  type        = string

}

variable "db_name" {
  description = "this is db name"
  type        = string

}

variable "db_username" {
  description = "this is database username"
  type        = string

}

variable "db_password" {
  description = "this is database password"
  type        = string

}

variable "db_security_group_ids" {
  description = "this is database security group ids"
  type        = list(string)

}