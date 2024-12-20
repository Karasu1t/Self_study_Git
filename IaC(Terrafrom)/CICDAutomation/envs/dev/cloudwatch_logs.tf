# ------------------------------------
# CloudWatch Logs For ECS
# ------------------------------------

# ロググループ定義
resource "aws_cloudwatch_log_group" "ecs_app_logs" {
  name              = "/ecs/${var.project}-${var.environment}-ecs-app"
  retention_in_days = 1 # 必要に応じて保持期間を設定
}
