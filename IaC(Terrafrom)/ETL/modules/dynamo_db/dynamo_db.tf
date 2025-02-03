#テーブル作成
resource "aws_dynamodb_table" "sample_table" {
  name             = "sample_table"           # テーブル名
  billing_mode     = "PROVISIONED"        # キャパシティーモード
  write_capacity   = 1                    #DynamoDBテーブルに対する書き込み操作のスループットを指定
  read_capacity    = 1                    #DynamoDBテーブルに対する読み込み操作のスループットを指定
  hash_key         = "id"                 #テーブル内のアイテムを一意に識別する為の主要なキー
  range_key        = "price"            #ソートキー
  stream_enabled   = false                 #DynamoDB Streams
  stream_view_type = "NEW_AND_OLD_IMAGES" #ストリームレコードにどのデータを含めるかを制御するための設定

  #デフォルトのアイテムを作成
  attribute {
    name = "id"
    type = "N"
  }

  attribute {
    name = "price"
    type = "N"
  }

  #有効期限切れのデータを削除する
  ttl {
    enabled = false
  }

  #削除保護の無効化
  deletion_protection_enabled = false
}
