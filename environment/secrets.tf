resource "aws_secretsmanager_secret" "aurora_credentials" {
  name                    = "${var.org}-${var.env}-aurora-credentials"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "aurora_credentials" {
  secret_id     = aws_secretsmanager_secret.aurora_credentials.id
  secret_string = "{\"username\":\"postgres\", \"password\":\"${random_password.aurora_credentials_password.result}\"}"
}

resource "random_password" "aurora_credentials_password" {
  length  = 32
  special = false
}