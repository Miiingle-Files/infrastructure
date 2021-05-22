resource "aws_codecommit_repository" "platform" {
  repository_name = "net.miiingle.files.platform"
}

resource "aws_codecommit_trigger" "platform" {
  repository_name = aws_codecommit_repository.platform.repository_name

  trigger {
    name = "all"
    events = ["all"]
    destination_arn = aws_sns_topic.pipeline_events.arn
  }
}