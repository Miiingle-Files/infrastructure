module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.org}-${var.env}-vpc"

  cidr            = var.vpc_cidr
  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = var.vpc_private_cidrs
  public_subnets  = var.vpc_public_cidrs

  single_nat_gateway     = false
  enable_nat_gateway     = false
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}