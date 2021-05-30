resource "aws_codecommit_repository" "platform" {
  repository_name = "${var.reverse_domain}.platform"
}

resource "aws_codecommit_repository" "app_web" {
  repository_name = "${var.reverse_domain}.app.web"
}

resource "aws_codecommit_trigger" "platform" {
  repository_name = aws_codecommit_repository.platform.repository_name

  trigger {
    name            = "all"
    events          = ["all"]
    destination_arn = aws_sns_topic.pipeline_events.arn
  }
}

resource "aws_codecommit_trigger" "app_web" {
  repository_name = aws_codecommit_repository.app_web.repository_name

  trigger {
    name            = "all"
    events          = ["all"]
    destination_arn = aws_sns_topic.pipeline_events.arn
  }
}