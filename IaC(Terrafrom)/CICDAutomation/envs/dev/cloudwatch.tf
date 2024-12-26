# ------------------------------------
# CloudWatch Events
# ------------------------------------
resource "aws_cloudwatch_event_rule" "ecr_image_push" {
  name        = "ecr-image-push-rule"
  description = "Trigger CodePipeline when an image is pushed to ECR"

  event_pattern = jsonencode({
    "source" = ["aws.ecr"],
    "detail-type" = ["ECR Repository State Change"],
    "detail" = {
      "eventName" = ["PutImage"]
    }
  })
}

resource "aws_cloudwatch_event_target" "codepipeline_trigger" {
  rule      = aws_cloudwatch_event_rule.ecr_image_push.name
  target_id = "StartCodePipeline"

  arn = aws_codepipeline.ecs_deploy_pipeline.arn
  role_arn = aws_iam_role.eventbridge_to_codepipeline_role.arn
}
