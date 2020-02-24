output "lambda_arn" {
  value = "${aws_lambda_function.lambda_function.arn}"
}

output "sqs_queue_arn" {
  value = "${aws_sqs_queue.sqs_queue_fifo.arn}"
}