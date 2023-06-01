resource "aws_lambda_function" "lambda_function" {
  filename         = "function.zip"
  source_code_hash = filebase64sha256("./function.zip")
  function_name    = "${var.project}-${var.env}"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "handlers.lambda_handler"
  description      = var.description
  timeout          = 30
  memory_size      = 256
  runtime          = "python3.10"

  tags = {
    Project     = "${var.project}"
    Environment = "${var.env}"
    AWSRegion   = "${var.aws_region}"
  }

  environment {
    variables = {
      Environment = "${var.env}"
      SecretName  = aws_secretsmanager_secret.secret.name
      AWSRegion   = "${var.aws_region}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_mapping" {
  event_source_arn = aws_sqs_queue.sqs_queue_fifo.arn
  function_name    = aws_lambda_function.lambda_function.arn
}