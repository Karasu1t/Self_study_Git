import sys
import boto3
import pandas as pd
import logging
from decimal import Decimal
from io import StringIO
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.dynamicframe import DynamicFrame

# ロギング設定
logging.basicConfig(level=logging.INFO)

# 引数の取得
bucket_name, object_key, dynamodb_table = None, None, None
for i in range(len(sys.argv)):
    if sys.argv[i] == '--bucket_name':
        bucket_name = sys.argv[i + 1]
    elif sys.argv[i] == '--object_key':
        object_key = sys.argv[i + 1]
    elif sys.argv[i] == '--dynamodb_table':
        dynamodb_table = sys.argv[i + 1]

if not bucket_name or not object_key or not dynamodb_table:
    raise ValueError("Missing necessary arguments")

# AWS クライアント
s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(dynamodb_table)

# GlueContext 初期化
sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

try:
    # S3 から CSV を取得
    logging.info(f"Getting file from S3: {bucket_name}/{object_key}")
    response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
    csv_data = response['Body'].read().decode('utf-8')
    
    # pandas で DataFrame に変換
    df = pd.read_csv(StringIO(csv_data))
    logging.info("CSV data successfully loaded into DataFrame")
    
    # NaN を空文字に置き換え、データ型を変換
    df.fillna("", inplace=True)
    df['id'] = df['id'].astype(int)
    df['price'] = df['price'].apply(lambda x: Decimal(str(x)))
    df['description'] = df['description'].astype(str)
    print(1)
    # DynamoDB にバッチ書き込み
    with table.batch_writer() as batch:
        for _, row in df.iterrows():
            batch.put_item(Item={
                'id': row['id'],
                'price': row['price'],
                'description': row['description']
            })
    
    logging.info("Data successfully written to DynamoDB")
    
except Exception as e:
    logging.error(f"An error occurred: {str(e)}")
    raise
