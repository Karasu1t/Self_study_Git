# ------------------------------------
# S3 Bucket (静的Webホスティング設定)
# ------------------------------------

#Sバケット名
resource "aws_s3_bucket" "static_site" {
  bucket        = "${var.project}-static-site"
  force_destroy = true #destroyした際に削除されるようにする
}

#オブジェクトの所有権をバケット所有者に変更
resource "aws_s3_bucket_ownership_controls" "bucket_ownership_control" {
  bucket = aws_s3_bucket.static_site.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#S3バケットポリシー設定
resource "aws_s3_bucket_policy" "my_bucket_policy" {
  depends_on = [
    aws_s3_bucket.static_site,
    aws_s3_bucket_public_access_block.bucket_public_access_block #依存関係がないとバケットポリシーが反映されない
  ]
  bucket = aws_s3_bucket.static_site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

#S3 パブリックアクセスの制御(有効化)
resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "my_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_ownership_control,
    aws_s3_bucket_public_access_block.bucket_public_access_block,
  ]
  bucket = aws_s3_bucket.static_site.id
  acl    = "public-read"
}

#S3バケットの静的ウェブサイトホスティング化
resource "aws_s3_bucket_website_configuration" "my_bucket_website" {
  bucket = aws_s3_bucket.static_site.id
  index_document {
    suffix = "index.html"
  }
}

#バージョニングの無効化(デフォルトは無効)
resource "aws_s3_bucket_versioning" "static_site_versioning" {
  bucket = aws_s3_bucket.static_site.bucket
  versioning_configuration {
    status = "Disabled"
  }
}

# # ------------------------------------
# # S3 Bucket (コンテンツ配信用) #※署名付きURLのためポリシーや権限に関する設定はしていない
# # ------------------------------------

#Sバケット名
resource "aws_s3_bucket" "broadcast_site" {
  bucket        = "${var.project}-broadcast-site"
  force_destroy = true #destroyした際に削除されるようにする
}

#S3バケット内のオブジェクト定義(S3バケットにオブジェクトを事前に格納)
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.broadcast_site.bucket
  key          = "Pancake.JPG"
  source       = "contents/Pancake.JPG" #格納予定の対象をパスで指定
  content_type = "image/jpeg"
}
