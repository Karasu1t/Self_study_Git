import json
import boto3

def lambda_handler(event, context):

    print("Started Lambda")

    # SQSメッセージのbodyを解析
    for record in event['Records']:
        message_body = json.loads(record['body'])
        s3_event = message_body['Records'][0]  # イベント情報の取得
        
        # S3情報(バケット名,オブジェクト名)を取得
        bucket_name = s3_event['s3']['bucket']['name']
        object_key = s3_event['s3']['object']['key']
        
        # S3クライアントを作成
        s3_client = boto3.client('s3')
        glue_client = boto3.client('glue')
        
        try:
            # S3からファイルを取得
            response = s3_client.get_object(Bucket=bucket_name, Key=object_key)

            print(f"Bucket Name : {bucket_name}")
            print(f"File Name : {object_key}")
            
            # Glueジョブを開始
            glue_job_name = "transform_csv_glue_job"
            response = glue_client.start_job_run(
                JobName=glue_job_name,
                Arguments={
                    "--bucket_name": bucket_name,
                    "--object_key": object_key,
                    "--dynamodb_table": 'sample_table'
                }
            )
            print(f"Started Glue job: {response['JobRunId']}")
            
        except Exception as e:
            print(f"Error processing S3 file or starting Glue job: {str(e)}")
            raise e