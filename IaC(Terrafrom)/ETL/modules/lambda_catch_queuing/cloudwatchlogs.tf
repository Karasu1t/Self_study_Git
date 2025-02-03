# ------------------------------------
# CloudWatch Logs For ECS
# ------------------------------------

# ロググループ定義
resource "aws_cloudwatch_log_group" "transport_to_glue" {
  name              = "/aws/lambda/transport_to_glue"
  retention_in_days = 1 # 必要に応じて保持期間を設定
}
