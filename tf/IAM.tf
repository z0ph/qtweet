resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.project}-${var.env}-lambda-role"
  assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Action": "sts:AssumeRole",
		"Principal": {
			"Service": "lambda.amazonaws.com"
		},
		"Effect": "Allow"
	}]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project}-${var.env}-policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = <<-EOF
	{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"sqs:DeleteMessage",
				"sqs:GetQueueAttributes",
				"sqs:ReceiveMessage"
			],
			"Resource": "${aws_sqs_queue.sqs_queue_fifo.arn}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"secretsmanager:GetSecretValue"
			],
			"Resource": [
				"${aws_secretsmanager_secret.secret.arn}"
			]
		}
	]
	}
	EOF
}

