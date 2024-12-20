# ---------------------------------------------
# IAM Role
# ---------------------------------------------

# ECS タスク実行ロール
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CodeDeployのサービスロール
resource "aws_iam_role" "codedeploy_role" {
  name = "${var.project}-${var.environment}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ECS リソースへのアクセスを追加するポリシー
resource "aws_iam_policy" "codedeploy_ecs_policy" {
  name        = "${var.project}-${var.environment}-codedeploy-ecs-policy"
  description = "Policy to allow CodeDeploy to describe ECS services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "ecs:DescribeServices"
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = "ecs:DescribeTaskDefinition"
        Effect = "Allow"
        Resource = "*"
      },
      {
        Action = "ecs:UpdateService"
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_ecs_policy_attach" {
  policy_arn = aws_iam_policy.codedeploy_ecs_policy.arn
  role       = aws_iam_role.codedeploy_role.name
}

# AWSCodeDeployRoleForECS ポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "codedeploy_policy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}
