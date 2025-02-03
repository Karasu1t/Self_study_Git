resource "aws_s3_bucket" "s3_transformfrom" {
  bucket        = "${var.project}-${var.environment}-from"
  force_destroy = true
}

#オブジェクトの所有権をバケット所有者に変更
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_control" {
  bucket = aws_s3_bucket.s3_transformfrom.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# SQSキューへの権限付与
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3_transformfrom.id

  queue {
    queue_arn     = aws_sqs_queue.from_s3_to_lambda_queue.arn
    events        = ["s3:ObjectCreated:Put"]
    filter_suffix       = ".csv"
  }
}