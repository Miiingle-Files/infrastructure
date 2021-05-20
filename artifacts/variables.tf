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

variable "registry_prefix" {
  default = "net.miiingle.files"
}