# ------------------------------------------------------------------------
# Lambda (事前処理)
# ------------------------------------------------------------------------

#ソースファイルの参照先(.pyファイルの格納先の指定 ※自動でzip化される)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "src"
  output_path = "src/src.zip"
}

# ------------------------------------------------------------------------
# Lambda HTMLフォームからのレスポンス受信
# ------------------------------------------------------------------------

#【概要】
#ローカル端末から静的Webホスティングとして利用するindex.htmlに回答した内容を
#AGI Gatewey(HTTP API)を経由して取得する

#ファンクション名
resource "aws_lambda_function" "import_html_dynamodb" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "import_html_dynamodb"
  role             = aws_iam_role.lambda_front_role.arn
  handler          = "import_html_dynamodb.lambda_handler" #「XXX.lambda_handler」のXXXXの部分は、srcフォルダ配下のpyファイル名と合わせる
  runtime          = "python3.12"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      SAVEBUCKET = "${aws_s3_bucket.broadcast_site.bucket}"
      MAILFROM = "${var.address}"
    }
  }
}

# トリガーの設定(API GatewayからLambdaの呼び出し)
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.import_html_dynamodb.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/${aws_apigatewayv2_stage.default_stage.name}/*"
}
