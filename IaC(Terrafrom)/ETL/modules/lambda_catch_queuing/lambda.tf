#ソースファイルの参照先(.pyファイルの格納先の指定 ※自動でzip化される)
data "archive_file" "transport_to_glue_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/src/upload/transport_to_glue.zip"
}

resource "aws_lambda_function" "transport_to_glue" {
  filename         = data.archive_file.transport_to_glue_zip.output_path
  function_name    = "transport_to_glue"
  role             = aws_iam_role.lambda_execution_transport_to_glue_role.arn
  handler          = "transport_to_glue.lambda_handler"
  runtime          = "python3.13"
  source_code_hash = data.archive_file.transport_to_glue_zip.output_base64sha256
  timeout          = 20
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = var.sqs_arn
  function_name    = aws_lambda_function.transport_to_glue.arn
  batch_size = 1
}