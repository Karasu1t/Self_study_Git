# ---------------------------------------------
# ECS(fargate)
# ---------------------------------------------
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name    = "${var.project}-${var.environment}-cluster"
    Project = var.project
    Env     = var.environment
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 1
    capacity_provider = "FARGATE"
  }
}

# ---------------------------------------------
# ECS(タスク定義)
# ---------------------------------------------
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.project}-${var.environment}-task" # タスク定義の名前
  cpu                      = "256"                                    # vCPU（0.25 vCPU）
  memory                   = "512"                                    # メモリ（512MB）
  network_mode             = "awsvpc"                                 # ネットワークモード
  requires_compatibilities = ["FARGATE"]                              # Fargateを使用
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn # タスク実行ロール
  #task_role_arn            = aws_iam_role.ecs_task_role.arn          # タスクロール

  runtime_platform {
    operating_system_family = "LINUX"  # OSを指定（LINUXまたはWINDOWS）
    cpu_architecture        = "X86_64" # CPUアーキテクチャ（X86_64またはARM64）
  }

  container_definitions = jsonencode([
    {
      name      = "app-container"                          # コンテナ名
      image     = "public.ecr.aws/nginx/nginx:stable-perl" # 使用するDockerイメージ
      cpu       = 128                                      # コンテナで使用するCPU単位
      memory    = 256                                      # コンテナで使用するメモリ（MB）
      essential = true                                     # コンテナが必須かどうか

      portMappings = [
        {
          containerPort = 80 # コンテナの内部ポート
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_app_logs.name
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
