# ------------------------------------
# Code Pipeline(ECS)
# ------------------------------------

resource "aws_codepipeline" "ecs_deploy_pipeline" {
  name = "${var.project}-${var.environment}-ecs-deploy-pipeline"
  role_arn = aws_iam_role.codepipeline_service_role.arn

  artifact_store {
    location = "karasuit"
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["SourceOutput"]

      configuration = {
        S3Bucket = aws_s3_bucket.s3_codedeploy.bucket
        S3ObjectKey = "artifact.zip"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeployToECS"
      version          = "1"
      input_artifacts  = ["SourceOutput"]
      configuration = {
        ApplicationName = aws_codedeploy_app.ecs_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.ecs_deployment_group.deployment_group_name
        TaskDefinitionTemplateArtifact = "SourceOutput"
        TaskDefinitionTemplatePath     = "ecs-task-definition.json"
        AppSpecTemplateArtifact    = "SourceOutput"
        AppSpecTemplatePath        = "appspec.yaml"
      }
    }
  }
}