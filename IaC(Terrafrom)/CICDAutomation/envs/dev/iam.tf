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
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ]
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

# CodePipelineのサービスロール
resource "aws_iam_role" "codepipeline_service_role" {
  name = "${var.project}-${var.environment}-codepipeline-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_service_policy" {
  name   = "${var.project}-${var.environment}-codepipeline-service-policy"
  role   = aws_iam_role.codepipeline_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:ListDeployments",
          "codedeploy:GetApplication",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetApplicationRevision",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "s3:GetObject",
          "s3:PutObject",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetImage",
          "ecr:DescribeImages",
          "ecr:GetDownloadUrlForLayer"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

#CloudWatch Events
resource "aws_iam_role" "eventbridge_to_codepipeline_role" {
  name = "eventbridge-to-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge_to_codepipeline_policy" {
  name = "eventbridge-to-codepipeline-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codepipeline:StartPipelineExecution"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_eventbridge_to_codepipeline_policy" {
  role       = aws_iam_role.eventbridge_to_codepipeline_role.name
  policy_arn = aws_iam_policy.eventbridge_to_codepipeline_policy.arn
}


