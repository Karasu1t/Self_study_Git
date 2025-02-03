import sys
import boto3
import pandas as pd
from io import StringIO
from awsglue.dynamicframe import DynamicFrame
from pyspark.context import SparkContext
from awsglue.context import GlueContext
import logging

# ロギングの設定
logging.basicConfig(level=logging.INFO)

# 引数を受け取る
bucket_name = None
object_key = None
output_bucket = None

for i in range(len(sys.argv)):
    if sys.argv[i] == '--bucket_name':
        bucket_name = sys.argv[i + 1]
    if sys.argv[i] == '--object_key':
        object_key = sys.argv[i + 1]
    if sys.argv[i] == '--output_bucket':
        output_bucket = sys.argv[i + 1]

# 引数が不足していた場合はエラーを発生させる
if not bucket_name or not object_key or not output_bucket:
    raise ValueError("Missing necessary arguments")

# AWSのクライアントを初期化
s3_client = boto3.client('s3')

# GlueContextの初期化
sc = SparkContext()
glueContext = GlueContext(sc)

try:
    # S3からCSVファイルを取得
    logging.info(f"Getting file from S3: {bucket_name}/{object_key}")
    response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
    csv_data = response['Body'].read().decode('utf-8')

    # pandasを使ってCSVデータをDataFrameに変換
    df = pd.read_csv(StringIO(csv_data))
    logging.info(f"CSV data successfully loaded into DataFrame")

    # 文字コードをUTF-8に変換
    df = df.applymap(lambda x: str(x).encode('utf-8').decode('utf-8') if isinstance(x, str) else x)

    # pandas DataFrameをSpark DataFrameに変換
    spark_df = glueContext.spark_session.createDataFrame(df)

    # DataFrameをDynamicFrameに変換
    dynamic_frame = DynamicFrame.fromDF(spark_df, glueContext, "dynamic_frame")
    dynamic_frame = dynamic_frame.coalesce(1)

    # 出力先S3のパスを設定
    output_key = object_key.split("/")[-1]
    output_path = f"s3://{output_bucket}/"

    # 変換したデータをS3に保存
    glueContext.write_dynamic_frame.from_options(dynamic_frame, connection_type="s3", connection_options={"path": output_path}, format="csv")
    logging.info(f"File successfully converted and saved to: {output_path}")

except ValueError as ve:
    logging.error(f"ValueError: {str(ve)}")
except boto3.exceptions.S3UploadFailedError as s3e:
    logging.error(f"S3 Upload Failed Error: {str(s3e)}")
except botocore.exceptions.EndpointConnectionError as e:
    logging.error(f"S3 Download Error: {str(e)}")
except Exception as e:
    logging.error(f"An unexpected error occurred: {str(e)}")
