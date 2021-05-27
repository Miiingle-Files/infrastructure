module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.org}-${var.env}-vpc"

  cidr            = var.vpc_cidr
  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = var.vpc_private_cidrs
  public_subnets  = var.vpc_public_cidrs

  single_nat_gateway     = true
  enable_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = local.common_tags
}