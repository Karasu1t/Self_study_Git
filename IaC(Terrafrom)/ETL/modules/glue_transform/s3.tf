#Glue job格納用
resource "aws_s3_bucket" "s3_glue_job" {
  bucket        = "${var.project}-${var.environment}-gluejob-seikabutu"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_control" {
  bucket = aws_s3_bucket.s3_glue_job.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#ETL処理後データ格納用
resource "aws_s3_bucket" "s3_put_artifacts" {
  bucket        = "${var.project}-${var.environment}-transformed-csvdata"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "bucket_ownership_control2" {
  bucket = aws_s3_bucket.s3_put_artifacts.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
