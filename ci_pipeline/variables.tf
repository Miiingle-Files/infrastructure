locals {
  common_tags = {
    org = var.org
    env = "shared"
  }
}

variable "org" {
  description = "Name of the Organization"
  type        = string
}

variable "reverse_domain" {}

variable "sms_destination" {
  default = "0917***"
}