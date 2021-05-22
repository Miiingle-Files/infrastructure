resource "aws_codebuild_project" "platform" {
  name                   = "${var.org}_platform"
  description            = "Build the docker image for the Lambda function the primarily carries the role of the API"
  badge_enabled          = true
  build_timeout          = 20
  concurrent_build_limit = 1
  service_role           = aws_iam_role.code_pipeline.arn

  source_version = "master"

  source {
    type     = "CODECOMMIT"
    location = aws_codecommit_repository.platform.clone_url_http
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_LARGE"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode = true

    environment_variable {
      name  = "RDS_CLUSTER_ARN"
      value = var.dev_rds_cluster_arn
    }

    environment_variable {
      name  = "RDS_CLUSTER_DATABASE"
      value = var.dev_rds_cluster_database
    }

    environment_variable {
      name  = "RDS_CLUSTER_SECRETS"
      value = var.dev_rds_cluster_secrets_arn
    }

    environment_variable {
      name  = "CONTAINER_REPOSITORY_URL"
      value = var.platform_repo_url
    }
  }

  vpc_config {
    security_group_ids = [var.dev_vpc_default_sg_id]
    subnets            = var.dev_vpc_private_subnets
    vpc_id             = var.dev_vpc_id
  }

  tags = local.common_tags
}

