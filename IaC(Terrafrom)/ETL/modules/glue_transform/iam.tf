resource "aws_iam_role" "transform_csv_glue_role" {
  name = "transform_csv_glue_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "glue_policy" {
  name       = "glue_policy_attachment"
  roles      = [aws_iam_role.transform_csv_glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_policy" "glue_policy" {
  name = "glue_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DescribeTable",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_transport_to_glue" {
  role       = aws_iam_role.transform_csv_glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}