resource "aws_cognito_user_pool" "main" {
  name = "${var.org}-${var.env}-main"
}