# ------------------------------------
# IAM Role/Policy For Lambda(Frontend)
# ------------------------------------

#CloudWatch Logに関するIAMロールは自動で付与されるので明示的に設定はしない

#IAMロール
resource "aws_iam_role" "lambda_front_role" {
  name               = "${var.project}-lambda-front-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

#Lambda実行用(IAMポリシー_AWS提供)
resource "aws_iam_role_policy_attachment" "lambda_lambda_policy" {
  role       = aws_iam_role.lambda_front_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#S3への読み書き用(IAMポリシー [マネージドポリシーとしてアタッチ])
resource "aws_iam_policy" "lambda_s3_policy" {
  name = "${var.project}-lambda-s3-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.broadcast_site.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.broadcast_site.bucket}/*",
        ]
      }
    ]
  })
}

#IAMポリシーをIAMロールにアタッチ
resource "aws_iam_role_policy_attachment" "lambda_s3_policy" {
  role       = aws_iam_role.lambda_front_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

#bynamo DBの読み書き用(IAMポリシー [マネージドポリシーとしてアタッチ])
resource "aws_iam_policy" "lambda_dynamodb_ro_policy" {
  name = "${var.project}-lambda_dynamodb_ro_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          #"dynamodb:Scan",(スキャンは負荷がかかるので使用しない)
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.user_table.name}",
          "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.sequence_table.name}"
        ]
      }
    ]
  })
}

# IAMポリシーをIAMロールにアタッチ
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_ro_policy" {
  role       = aws_iam_role.lambda_front_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_ro_policy.arn
}

#SESの送受信用(IAMポリシー [マネージドポリシーとしてアタッチ])
#SESは、デフォルトサンドボックス環境なので、予め認証を済ませたメールアドレスにのみ送受信が可能なので
#明示的にResourceの項目を個別ですることは難しいので、「*」とする。

resource "aws_iam_policy" "lambda_ses_policy" {
  name = "${var.project}-lambda-ses-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        "Resource" : "*" 
      }
    ]
  })
}

#IAMポリシーをIAMロールにアタッチ
resource "aws_iam_role_policy_attachment" "lambda_ses_policy" {
  role       = aws_iam_role.lambda_front_role.name
  policy_arn = aws_iam_policy.lambda_ses_policy.arn
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }
  }
}

################################
# IAM Role/Policy For API Gateway
################################

resource "aws_iam_role" "api_gateway_role" {
  name               = "${var.project}-apigateway-role"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role.json
}

resource "aws_iam_role_policy_attachment" "api_gateway_policy_logs" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_iam_role_policy_attachment" "api_gateway_policy_lambda" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

data "aws_iam_policy_document" "api_gateway_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}