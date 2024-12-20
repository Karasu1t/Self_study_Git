# ------------------------------------
# Terraform Cofiguration
# ------------------------------------
terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "env_dev" {
  source      = "./envs/dev"
  region      = var.region
  project     = var.project
  environment = var.environment_dev
}
