resource "aws_codebuild_project" "platform" {
  name          = "${var.reverse_domain}.platform"
  description   = "Build the docker image for the Lambda function the primarily carries the role of the API"
  badge_enabled = true
  build_timeout = 20
  service_role  = aws_iam_role.code_build.arn

  source {
    type = ""
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type         = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_LARGE"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"

    environment_variable {
      name = "RDS_CLUSTER_ARN"
      value = var.dev_rds_cluster_arn
    }

    environment_variable {
      name = "RDS_CLUSTER_DATABASE"
      value = var.dev_rds_cluster_database
    }

    environment_variable {
      name = "RDS_CLUSTER_SECRETS"
      value = var.dev_rds_cluster_secrets_arn
    }
  }
}

resource "aws_iam_role" "code_build" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "code_build" {
  role = aws_iam_role.code_build.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": ["*"]
    }
  ]
}
POLICY
}