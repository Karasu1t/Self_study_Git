# ---------------------------------------------
# Dynamo DB (user:ユーザ情報登録用テーブル)
# ---------------------------------------------

#テーブル作成
resource "aws_dynamodb_table" "user_table" {
  name           = "user"        # テーブル名
  billing_mode   = "PROVISIONED" # キャパシティーモード
  write_capacity = 1             #DynamoDBテーブルに対する書き込み操作のスループットを指定
  read_capacity  = 1             #DynamoDBテーブルに対する読み込み操作のスループットを指定
  hash_key       = "id"          # テーブル内のアイテムを一意に識別する為の主要なキー
  stream_enabled   = true                 #DynamoDB Streams
  stream_view_type = "NEW_AND_OLD_IMAGES" #ストリームレコードにどのデータを含めるかを制御するための設定

  attribute {
    name = "id"
    type = "N" #　String型の[S] (Numberなら（N）)
  }

  ttl {
    #attribute_name = "TimeToExist" #有効期限切れのデータを削除する
    enabled = false
  }

  deletion_protection_enabled = false #削除保護

  tags = {
    Name        = "${var.project}_user"
    Environment = "${var.environment}"
  }

  #グローバルインデックス(今回は使用しないので不要)
  # global_secondary_index {
  #   name               = "sepal_length"
  #   hash_key           = "sepal_length"
  #   range_key          = "kind"
  #   write_capacity     = 10
  #   read_capacity      = 10
  #   projection_type    = "INCLUDE"
  #   non_key_attributes = ["sepal_length", "kind"]
  # }

  #ローカルインデックス(今回は使用しないので不要)
  # local_secondary_index {
  #   name               = "ReleaseDateIndex"
  #   range_key          = "ReleaseDate"
  #   projection_type    = "INCLUDE"
  #   non_key_attributes = ["Artist", "SongTitle", "Genre"]
  # }
}

# ---------------------------------------------
# Dynamo DB (sequence:ユーザ情報登録用テーブル用のアトミックカウント用テーブル)
# ---------------------------------------------

#テーブル作成
resource "aws_dynamodb_table" "sequence_table" {
  name             = "sequence"           # テーブル名
  billing_mode     = "PROVISIONED"        # キャパシティーモード
  write_capacity   = 1                    #DynamoDBテーブルに対する書き込み操作のスループットを指定
  read_capacity    = 1                    #DynamoDBテーブルに対する読み込み操作のスループットを指定
  hash_key         = "tablename"          #テーブル内のアイテムを一意に識別する為の主要なキー
  range_key        = "comment"            #ソートキー
  stream_enabled   = true                 #DynamoDB Streams
  stream_view_type = "NEW_AND_OLD_IMAGES" #ストリームレコードにどのデータを含めるかを制御するための設定

  #デフォルトのアイテムを作成
  attribute {
    name = "tablename"
    type = "S" #　String型の[S] (Numberなら（N）)
  }

  attribute {
    name = "comment"
    type = "S" #　String型の[S] (Numberなら（N）)
  }

  #有効期限切れのデータを削除する
  ttl {
    #attribute_name = "TimeToExist"
    enabled = false
  }

  #削除保護の無効化
  deletion_protection_enabled = false

  #タグ付け
  tags = {
    Name        = "${var.project}_sequence"
    Environment = "${var.environment}"
  }

}

resource "null_resource" "put_initial_item" {
  provisioner "local-exec" {
  interpreter = ["C:/Program Files/Git/bin/bash.exe", "-c"] #GitBashの指定(デフォルトだとCMD.exeで使いづらい)
      command = <<EOT
      echo "Executing DynamoDB put-item command..."
      aws dynamodb put-item --table-name sequence --item '{"tablename": {"S": "user"}, "comment": {"S": "アトミックカウンタ"}, "seq": {"N": "0"}}' --region ap-northeast-1
      echo "Finished DynamoDB put-item command..."
    EOT 
  }

  depends_on = [aws_dynamodb_table.sequence_table]
}