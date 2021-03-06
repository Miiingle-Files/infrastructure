locals {
  common_tags = {
    org = var.org
    env = var.env
  }
}

#Common
variable "org" {
  description = "Name of the Organization"
  type        = string
}

variable "env" {
  description = "Name of the Environment"
  type        = string
}

variable "aws_region" {
  description = "AWS Resources created region"
  type        = string
}

#VPC
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_public_cidrs" {
  description = "CIDR for public Subnet"
  type        = list(string)
}

variable "vpc_private_cidrs" {
  description = "CIDR for private Subnet"
  type        = list(string)
}

#Platform Config
variable "platform_repository_url" {}

#DNS
variable "dns_root" {}
variable "dns_prefix_api" {}
variable "dns_prefix_auth" {}
variable "dns_prefix_web" {}