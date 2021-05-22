resource "aws_sns_topic" "pipeline_events" {
  name         = "${var.org}_pipeline_events"
  display_name = "${upper(var.org)} Pipeline Events"
}

resource "aws_sns_topic_subscription" "pipeline_sms" {
  topic_arn = aws_sns_topic.pipeline_events.arn
  protocol  = "sms"
  endpoint  = var.sms_destination

  delivery_policy = ""
  filter_policy   = ""

  lifecycle {
    ignore_changes = [endpoint]
  }
}