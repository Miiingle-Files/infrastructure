output "rds_cluster_arn" {
  value = aws_rds_cluster.main.arn
}

output "rds_cluster_secret_arn" {
  value = aws_secretsmanager_secret.aurora_credentials.arn
}

output "rds_cluster_database" {
  value = aws_rds_cluster.main.database_name
}