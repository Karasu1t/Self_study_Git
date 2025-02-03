# ------------------------------------
# SQS (S3バケットへのPutObject情報を取得)
# ------------------------------------
# SQSキューの作成
resource "aws_sqs_queue" "from_s3_to_lambda_queue" {
  name = "${var.project}-${var.environment}-to_lambda_queue"

  visibility_timeout_seconds = 30

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
    maxReceiveCount     = 2
  })
}

resource "aws_sqs_queue" "dead_letter_queue" {
  name = "${var.project}-${var.environment}-dead_letter_queue"
}

# SQSキューのポリシー（S3からの通知を許可）
resource "aws_sqs_queue_policy" "from_s3_to_lambda_queue_policy" {
  queue_url = aws_sqs_queue.from_s3_to_lambda_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sqs:SendMessage"
        Resource = aws_sqs_queue.from_s3_to_lambda_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.s3_transformfrom.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "dead_letter_queue" {
  queue_url = aws_sqs_queue.dead_letter_queue.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.from_s3_to_lambda_queue.arn]
  })
}