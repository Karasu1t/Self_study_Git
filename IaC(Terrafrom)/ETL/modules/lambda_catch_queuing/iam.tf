resource "aws_iam_role" "lambda_execution_transport_to_glue_role" {
  name = "lambda_execution_transport_to_glue_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_execution_transport_to_glue_policy" {
  name = "lambda_execution_transport_to_glue_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "s3:GetObject",
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJob"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_transport_to_glue" {
  role       = aws_iam_role.lambda_execution_transport_to_glue_role.name
  policy_arn = aws_iam_policy.lambda_execution_transport_to_glue_policy.arn
}