resource "aws_codepipeline" "platform" {
  name     = "${var.org}-platform-pipeline"
  role_arn = aws_iam_role.code_pipeline.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "CodeCommit"
      version  = "1"

      configuration = {
        RepositoryName = aws_codecommit_repository.platform.repository_name
        BranchName     = "master"
      }

      output_artifacts = ["source_output"]
    }
  }

  stage {
    name = "Build"

    action {
      name      = "Unit_Test"
      category  = "Test"
      owner     = "AWS"
      provider  = "CodeBuild"
      version   = "1"
      run_order = 1

      namespace = "Unit_Test"

      configuration = {
        ProjectName = aws_codebuild_project.platform_test.name
      }

      input_artifacts = ["source_output"]
    }

    action {
      name      = "Publish_to_ECR"
      category  = "Build"
      owner     = "AWS"
      provider  = "CodeBuild"
      version   = "1"
      run_order = 2

      namespace = "Publish_To_ECR"

      configuration = {
        ProjectName = aws_codebuild_project.platform_publish_to_ecr.name
      }

      input_artifacts = ["source_output"]
    }

  }

  stage {
    name = "Deploy_to_Dev"

    action {
      name      = "Publish_to_Lambda"
      category  = "Build"
      owner     = "AWS"
      provider  = "CodeBuild"
      version   = "1"
      run_order = 1

      configuration = {
        ProjectName = aws_codebuild_project.platform_publish_to_lambda.name
        EnvironmentVariables = jsonencode([
          {
            name  = "IMAGE_URI"
            value = "#{Publish_To_ECR.IMAGE_URI}"
          }
        ])
      }

      input_artifacts  = ["source_output"]
      output_artifacts = ["dev_appspec"]
    }

    //TODO: temporarily do this
    //https://awscli.amazonaws.com/v2/documentation/api/latest/reference/deploy/create-deployment.html
    action {
      name      = "Deploy_WorkAround"
      category  = "Build"
      owner     = "AWS"
      provider  = "CodeBuild"
      version   = "1"
      run_order = 2

      configuration = {
        ProjectName = aws_codebuild_project.platform_fake_deploy.name
      }

      input_artifacts = ["dev_appspec"]
    }

    //TODO: fix this once we figure out how to integrate codedeploy properly into codepipeline
    //    action {
    //      name     = "Deploy"
    //      category = "Deploy"
    //      owner    = "AWS"
    //      provider = "CodeDeploy"
    //      version  = "1"
    //      run_order = 2
    //
    //      configuration = {
    //        ApplicationName     = aws_codedeploy_app.platform.name
    //        DeploymentGroupName = aws_codedeploy_deployment_group.platform.deployment_group_name
    //      }
    //
    //      input_artifacts = ["dev_appspec"]
    //    }
  }
}

resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "${var.reverse_domain}.pipeline.artifacts"
}

resource "aws_iam_role" "code_pipeline" {
  name               = "${var.org}-codepipeline-role"
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
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
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
  role       = aws_iam_role.code_pipeline.name
}

//TODO: refine the policy, use the link below as reference
//https://github.com/miiingle/infrastructure/blob/main/shared/ci/template/codebuild_policy.json
resource "aws_iam_role_policy" "code_build" {
  name = "${var.org}-codepipeline-shared-policy"
  role = aws_iam_role.code_pipeline.name

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