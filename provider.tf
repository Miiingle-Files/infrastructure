provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 0.15"
  backend "s3" {
    bucket  = "net.miiingle.files.infra"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}