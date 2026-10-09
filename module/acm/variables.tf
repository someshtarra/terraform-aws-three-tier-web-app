variable "domain_name" {
  description = "this is domain name for 3 tier project"
  type        = string

}

variable "san_name" {
  description = "List of Subject Alternative Names (SANs) for the certificate"
  type        = list(string)
  default     = []
}



