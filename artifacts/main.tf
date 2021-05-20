resource "aws_ecr_repository" "platform" {
  name = "${var.registry_prefix}.platform"

  tags = local.common_tags
}