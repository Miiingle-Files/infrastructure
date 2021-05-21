resource "aws_rds_cluster" "main" {
  cluster_identifier = "${var.org}-${var.env}-aurora-cluster"

  engine_mode    = "serverless"
  engine         = "aurora-postgresql"
  engine_version = "10.14"
  port           = 5432

  enable_http_endpoint = true

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 16
    min_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  database_name   = "${var.org}_${var.env}_data"
  master_username = jsondecode(aws_secretsmanager_secret_version.aurora_credentials.secret_string)["username"]
  master_password = jsondecode(aws_secretsmanager_secret_version.aurora_credentials.secret_string)["password"]

  vpc_security_group_ids = [aws_security_group.aurora.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
  availability_zones     = module.vpc.azs

  final_snapshot_identifier = "${var.org}-${var.env}-rds-final-snapshot-${formatdate("YYYYMMDDHHmm", timestamp())}"
  deletion_protection       = false
  backup_retention_period   = 7
  apply_immediately         = true

  tags = local.common_tags

  lifecycle {
    ignore_changes = [final_snapshot_identifier]
  }

  depends_on = [aws_secretsmanager_secret_version.aurora_credentials]
}

resource "aws_db_subnet_group" "rds_subnet" {
  name       = "${var.org}-${var.env}-aurora-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = local.common_tags
}

resource "aws_security_group" "aurora" {
  name        = "${var.org}-${var.env}-aurora-sg"
  description = "Allow traffic into Aurora Serverless"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.org}-${var.env}-aurora-sg"
  }, local.common_tags)
}
