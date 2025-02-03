output "sqs_arn" {
  value = aws_sqs_queue.from_s3_to_lambda_queue.arn
}

output "sqs_url" {
  value = aws_sqs_queue.from_s3_to_lambda_queue.id
}