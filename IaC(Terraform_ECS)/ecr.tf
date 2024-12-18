# ------------------------------------
# ECR(NginX)
# ------------------------------------
resource "aws_ecr_repository" "ECR-app" {
  name = "${var.project}-${var.environment}-rep-app"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = "false"
  }

  image_tag_mutability = "IMMUTABLE"

  tags = {
    Name    = "${var.project}-${var.environment}-rep-app"
    Project = var.project
    Env     = var.environment
  }
}
