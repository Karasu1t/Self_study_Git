# ------------------------------------
# S3 Bucket (Appspec.yml格納先)
# ------------------------------------

#Sバケット名
resource "aws_s3_bucket" "s3_codedeploy" {
  bucket        = "${var.project}-${var.environment}-codedeploy"
  force_destroy = true
}

#オブジェクトの所有権をバケット所有者に変更
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_control" {
  bucket = aws_s3_bucket.s3_codedeploy.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "s3_codedeploy" {
  bucket = aws_s3_bucket.s3_codedeploy.id
  versioning_configuration {
    status = "Enabled"
  }
}
