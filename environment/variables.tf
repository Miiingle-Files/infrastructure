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