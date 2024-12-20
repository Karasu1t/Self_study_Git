# ------------------------------------
# Code Deploy(ECS)
# ------------------------------------

resource "aws_codedeploy_app" "ecs_app" {
  name = "${var.project}-${var.environment}-codedeploy-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "ecs_deployment_group" {
  app_name = aws_codedeploy_app.ecs_app.name
  deployment_group_name = "${var.project}-${var.environment}-codedeploy-group"

  service_role_arn = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.ecs_cluster.name
    service_name = aws_ecs_service.ecs_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.alb_listener_http_80.arn]
      }

      target_group {
        name = aws_lb_target_group.alb_target_group_blue.name
      }

      target_group {
        name = aws_lb_target_group.alb_target_group_green.name
      }
    }
  }
}
