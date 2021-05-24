module "artifacts" {
  source = "./artifacts"
  org    = var.org
}

module "ci_pipeline" {
  source         = "./ci_pipeline"
  org            = var.org
  reverse_domain = var.reverse_domain

  sms_destination = var.admin_mobile_number

  dev_rds_cluster_arn         = module.dev_environment.rds_cluster_arn
  dev_rds_cluster_database    = module.dev_environment.rds_cluster_database
  dev_rds_cluster_secrets_arn = module.dev_environment.rds_cluster_secret_arn

  platform_repo_url = module.artifacts.platform_repository_url

  dev_vpc_id                        = module.dev_environment.vpc_id
  dev_vpc_private_subnets           = module.dev_environment.vpc_private_subnets
  dev_vpc_default_sg_id             = module.dev_environment.vpc_default_sg_id
  dev_lambda_platform_policy_arn    = module.dev_environment.lambda_policy_arn
  dev_lambda_platform_function_name = module.dev_environment.lambda_platform_function_name
  dev_lambda_platform_function_alias_name = module.dev_environment.lambda_platform_function_alias_name
}

module "dev_environment" {
  source = "./environment"

  org               = var.org
  env               = "dev"
  aws_region        = "us-east-1"
  vpc_cidr          = "10.10.0.0/16"
  vpc_public_cidrs  = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
  vpc_private_cidrs = ["10.10.128.0/20", "10.10.144.0/20", "10.10.160.0/20"]

  platform_repository_url = module.artifacts.platform_repository_url
}