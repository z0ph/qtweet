resource "aws_secretsmanager_secret" "secret" {
  name = "${var.project}-${var.env}"

  tags = {
    Project     = "${var.project}"
    Product     = "${var.product}"
    Environment = "${var.env}"
  }
}
