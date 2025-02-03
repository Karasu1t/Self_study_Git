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

# ------------------------------------
# S3 Bucket一式 (元データ格納用バケット)
# ------------------------------------
module "s3_from_s3_to_sqs" {
  source      = "../../modules/s3_from"
  project     = local.project
  environment = local.environment
}

# ------------------------------------
# Lambda 一式 (元データキューイング時実行用)
# ------------------------------------
module "execution_lambda_transport_to_glue" {
  source      = "../../modules/lambda_catch_queuing"
  project     = local.project
  environment = local.environment
  sqs_arn     = module.s3_from_s3_to_sqs.sqs_arn
}

# ------------------------------------
# Glue 一式 (lambda→Glue→SNSトピック)
# ------------------------------------
module "glue_transform" {
  source      = "../../modules/glue_transform"
  project     = local.project
  environment = local.environment
}

# ------------------------------------
# Dynamo_DB 一式
# ------------------------------------
module "dynamo_db" {
  source      = "../../modules/dynamo_db"
  project     = local.project
  environment = local.environment
}
