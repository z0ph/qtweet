resource "aws_sqs_queue" "sqs_queue_fifo" {
  name                              = "${var.project}-${var.env}-sqs-queue.fifo"
  fifo_queue                        = true
  content_based_deduplication       = true
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300

  tags = {
    Project     = "${var.project}"
    Product     = "${var.product}"
    Environment = "${var.env}"
  }
}
