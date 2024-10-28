# # ------------------------------------
# # CloudWatch Logs For Lambda
# # ------------------------------------

# ロググループ定義
resource "aws_cloudwatch_log_group" "lambad_import_html_dynamodb_logs" {
  name              = "/aws/lambda/${aws_lambda_function.import_html_dynamodb.function_name}"
  retention_in_days = 1 # 必要に応じて保持期間を設定

  # Lambda関数が削除されたときにロググループも削除されるように依存関係を設定
  depends_on = [aws_lambda_function.import_html_dynamodb]
}

# # ------------------------------------
# # CloudWatch Logs For API Gateway(HTTP API)
# # ------------------------------------

#ロググループ定義
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.http_api.name}"
  retention_in_days = 1 # 必要に応じて保持期間を設定

  # API Gatewayが削除されたときにロググループも削除されるように依存関係を設定
  depends_on = [aws_apigatewayv2_api.http_api]
}
