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

variable "dev_rds_cluster_arn" {}
variable "dev_rds_cluster_database" {}
variable "dev_rds_cluster_secrets_arn" {}