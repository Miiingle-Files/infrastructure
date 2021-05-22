resource "aws_codebuild_project" "platform" {
  name                   = "${var.org}_platform"
  description            = "Build the docker image for the Lambda function the primarily carries the role of the API"
  badge_enabled          = true
  build_timeout          = 20
  concurrent_build_limit = 1
  service_role           = aws_iam_role.code_build.arn

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

resource "aws_iam_role" "code_build" {
  name               = "${var.org}-codebuild-role"
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

  tags = local.common_tags
}

//our codebuild instance should have the same policy as the lambda runtime
resource "aws_iam_role_policy_attachment" "dev_lambda_policy_attachment" {
  policy_arn = var.dev_lambda_platform_policy_arn
  role       = aws_iam_role.code_build.name
}

//TODO: refine the policy, use the link below as reference
//https://github.com/miiingle/infrastructure/blob/main/shared/ci/template/codebuild_policy.json
resource "aws_iam_role_policy" "code_build" {
  name = "${var.org}-codebuild-shared-policy"
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
      "Effect" : "Allow",
      "Action" : [
        "codecommit:*"
      ],
      "Resource" : [
        "${aws_codecommit_repository.platform.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:us-east-1::network-interface/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "*"
      ],
      "Resource": ["*"]
    }
  ]
}
POLICY
}