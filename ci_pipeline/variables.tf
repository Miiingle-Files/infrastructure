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
variable "dev_vpc_id" {}
variable "dev_vpc_default_sg_id" {}
variable "dev_vpc_private_subnets" {}
variable "dev_lambda_platform_policy_arn" {}
variable "dev_lambda_platform_function_name" {}
variable "dev_lambda_platform_function_alias_name" {}

variable "platform_repo_url" {
  description = "ECR repository url of the platform image"
}