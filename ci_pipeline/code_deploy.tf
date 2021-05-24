resource "aws_codedeploy_app" "platform" {
  name             = "${var.org}-platform"
  compute_platform = "Lambda"

  tags = local.common_tags
}

resource "aws_codedeploy_deployment_group" "platform" {
  app_name               = aws_codedeploy_app.platform.name
  deployment_group_name  = "platform"
  service_role_arn       = aws_iam_role.code_pipeline.arn
  deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
}

//resource "aws_codedeploy_deployment_config" "platform" {
//  deployment_config_name = "${var.org}-platform-config"
//  compute_platform       = "Lambda"
//
//  traffic_routing_config {
//    type = "TimeBasedLinear"
//
//    time_based_linear {
//      interval   = 10
//      percentage = 10
//    }
//  }
//}