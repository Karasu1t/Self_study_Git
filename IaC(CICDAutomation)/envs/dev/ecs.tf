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

  runtime_platform {
    operating_system_family = "LINUX"  # OSを指定（LINUXまたはWINDOWS）
    cpu_architecture        = "X86_64" # CPUアーキテクチャ（X86_64またはARM64）
  }

  container_definitions = jsonencode([
    {
      name      = "${var.project}-${var.environment}-container"
      image     = "public.ecr.aws/nginx/nginx:stable-perl"
      cpu       = 128
      memory    = 256
      essential = true

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

# ECSサービス作成
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.project}-${var.environment}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.public_subnet_1a.id]
    security_groups  = [aws_security_group.web_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group_blue.arn
    container_name   = "${var.project}-${var.environment}-container"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.alb_listener_http_80
  ]
}

# ---------------------------------------------
# ECS(タスク実行定義)
# ---------------------------------------------
# resource "aws_ecs_task" "run_task" {
#   cluster        = aws_ecs_cluster.ecs_cluster.id
#   task_definition = aws_ecs_task_definition.ecs_task.arn

#   launch_type = "FARGATE"
#   network_configuration {
#     subnets         = var.subnet_ids
#     security_groups = [aws_security_group.web_in_http.id]
#     assign_public_ip = true
#   }

#   depends_on = [
#     aws_lb_listener.alb_listener_http_80
#   ]
# }
