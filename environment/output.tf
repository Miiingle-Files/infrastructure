output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_private_subnets" {
  value = module.vpc.private_subnets
}

output "vpc_default_sg_id" {
  value = module.vpc.default_security_group_id
}

output "rds_cluster_arn" {
  value = aws_rds_cluster.main.arn
}

output "rds_cluster_secret_arn" {
  value = aws_secretsmanager_secret.aurora_credentials.arn
}

output "rds_cluster_database" {
  value = aws_rds_cluster.main.database_name
}

output "lambda_policy_arn" {
  value = aws_iam_policy.lambda_logging.arn
}