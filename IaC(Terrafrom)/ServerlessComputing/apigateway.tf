# # ------------------------------------
# # API Gateway (From API Gateway To Lamnbda(HTTP API))
# # ------------------------------------

# API名
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project}-http-api"
  protocol_type = "HTTP"

  # CORS 設定
  cors_configuration {
    allow_origins  = ["*"]            # 許可するオリジン
    allow_methods  = ["GET", "POST"]  # 許可する HTTP メソッド
    allow_headers  = ["Content-Type"] # 許可するヘッダー
    expose_headers = []               # クライアントに公開するヘッダー
    max_age        = 86400            # プリフライトリクエストのキャッシュ時間（秒）
  }
}

# Lambda統合の設定
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.import_html_dynamodb.arn
  integration_method     = "POST"
  payload_format_version = "2.0" #HTTP APIのみに利用なので2.0を使用
}

# API Gatewayのルート設定
resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}" #API Gatewayが任意のパスをキャッチする
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# AWS API Gateway HTTP API のステージ定義
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "${var.project}-stage"
  auto_deploy = true

  # デフォルトルートの設定(全てに適用)
  default_route_settings {
    detailed_metrics_enabled = false
    throttling_burst_limit   = 5000
    throttling_rate_limit    = 10000
  }

  # ログ設定の有効化(CLFで出力)
  access_log_settings {
    destination_arn = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.api_gateway_logs.name}"
    format          = "$context.identity.sourceIp - $context.identity.caller [-] [$context.requestTime] \"$context.httpMethod $context.path $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}