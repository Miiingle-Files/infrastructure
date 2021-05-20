module "artifacts" {
  source = "./artifacts"
  org    = var.org
}

module "ci_pipeline" {
  source = "./ci_pipeline"
  org    = var.org
}

module "dev_environment" {
  source = "./environment"

  org               = var.org
  env               = "dev"
  aws_region        = "us-east-1"
  vpc_cidr          = "10.10.0.0/16"
  vpc_public_cidrs  = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
  vpc_private_cidrs = ["10.10.128.0/20", "10.10.144.0/20", "10.10.160.0/20"]
}