resource "aws_secretsmanager_secret" "CONSUMER_KEY" {
    name = "CONSUMER_KEY-${var.env}"

    tags = {
        Project     = "${var.project}"
        Environment = "${var.env}"
        }
}

resource "aws_secretsmanager_secret" "CONSUMER_SECRET" {
    name = "CONSUMER_SECRET-${var.env}"

    tags = {
        Project     = "${var.project}"
        Environment = "${var.env}"
        }
}

resource "aws_secretsmanager_secret" "ACCESS_TOKEN" {
    name = "ACCESS_TOKEN-${var.env}"

    tags = {
        Project     = "${var.project}"
        Environment = "${var.env}"
        }
}

resource "aws_secretsmanager_secret" "ACCESS_TOKEN_SECRET" {
    name = "ACCESS_TOKEN_SECRET-${var.env}"

    tags = {
        Project     = "${var.project}"
        Environment = "${var.env}"
        }
}
