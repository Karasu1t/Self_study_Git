resource "aws_glue_job" "transform_csv_glue_job" {
  name     = "transform_csv_glue_job"
  role_arn = aws_iam_role.transform_csv_glue_role.arn
  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.s3_glue_job.bucket}/glue-scripts/transform_csv.py"
    python_version  = "3"
  }
  default_arguments = {
    "--job-language"     = "python"
    "--TempDir"          = "s3://${aws_s3_bucket.s3_glue_job.bucket}/temp/"
  }
}

resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.s3_glue_job.bucket
  key    = "glue-scripts/transform_csv.py"
  source = "${path.module}/src/transform_csv.py" # ローカルのファイルパス
  acl    = "private"
}