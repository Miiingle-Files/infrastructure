resource "aws_lambda_function" "platform" {
  function_name = "${var.org}-${var.env}-platform"
  role          = aws_iam_role.iam_for_lambda.arn

  package_type = "Image"
  image_uri    = "${var.platform_repository_url}:latest"

  memory_size = 1024
  timeout     = 25

  environment {
    variables = {
      RDS_CLUSTER_ARN      = aws_rds_cluster.main.arn
      RDS_CLUSTER_DATABASE = aws_rds_cluster.main.database_name
      RDS_CLUSTER_SECRETS  = aws_secretsmanager_secret.aurora_credentials.arn
    }
  }

  vpc_config {
    security_group_ids = [module.vpc.default_security_group_id]
    subnet_ids         = module.vpc.private_subnets
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.platform_logs,
  ]

  lifecycle {
    ignore_changes = [image_uri, memory_size]
  }
}

resource "aws_lambda_alias" "platform_prod" {
  function_name    = aws_lambda_function.platform.function_name
  function_version = "$LATEST"
  name             = "prod"

  lifecycle {
    ignore_changes = [function_version]
  }
}