import json
import boto3
import base64
import time
import decimal
import os

#DynamoDBオブジェクトの取得
dynamodb = boto3.resource('dynamodb')

#S3オブジェクトの取得
s3 = boto3.client('s3')

#SESオブジェクトの取得
client = boto3.client('ses')
#送信元のメールアドレス
MAILFROM = os.environ['MAILFROM']

#メールの送信関数
def sendmail(to, subject, body):
    response = client.send_email(
        Source = MAILFROM, #送信元アドレス(検証の為自分自身にメールを送る)
        ReplyToAddresses = [MAILFROM], #送信先アドレス(りすとがたでいれる)
        Destination = {
            'ToAddresses' : [
                to
            ]
        },
        Message = {
            'Subject' : {
                'Data' : subject,
                'Charset' : 'UTF-8'
            },
            'Body' : {
                'Text' : {
                    'Data' : body,
                    'Charset' : 'UTF-8'
                }
            }
        }
    )

#連番を更新して返す変数(アトミックカウンタ)
def next_seq(table, tablename, comment):
    response = table.update_item(
        Key={
            'tablename': tablename, # パーティションキー
            'comment': comment # ソートキー
        },
        UpdateExpression="set seq = seq + :val", #既存の値から1繰り上げる
        ExpressionAttributeValues={ #1繰り上げるためのパラメータ設定
            ':val' :1
        },
        ReturnValues='UPDATED_NEW' #更新した値のみを戻り値として返す
    )
    return response['Attributes']['seq'] #ReturnValuesの戻り値(辞書型)から必要な情報を取得

def lambda_handler(event, context):
    try:
        #シーケンス番号を得る
        seqtable = dynamodb.Table('sequence')
        nextseq = next_seq(seqtable, 'user', 'アトミックカウンタ')

        #フォームに入力されたデータを得る
        body = event['body']
        if event['isBase64Encoded']:
            body = base64.b64decode(body)

        decoded = json.loads(body)
        username = decoded['username']
        email = decoded['email']

        #クライアント端末のIPアドレスを取得する
        host = event['requestContext']['http']['sourceIp']

        #現在のUNIXタイムスタンプを取得する
        now = time.time() #Float型なので別途str型に変換

        #署名付きURLを作成する
        url = s3.generate_presigned_url(
            ClientMethod = 'get_object',
            Params = {'Bucket' : os.environ['SAVEBUCKET'],
            'Key' : 'Pancake.JPG'},
            ExpiresIn = 4 * 60 * 60,
            HttpMethod = 'GET')

        #userテーブルに登録する
        usertable = dynamodb.Table('user')
        usertable.put_item(
            Item={
                'id'            : nextseq,
                'username'      : username,
                'email'         : email,
                'accepted_at'   : decimal.Decimal(str(now)),
                'host'          : host,
                'url'           : url
            }
        )

        #メールを送信する
        mailbody = """
        {0}様
        ご登録ありがとうございました。
        下記のURLからダウンロードできます。
        {1}
        """.format(username,url)
        
        sendmail(email, "ご登録ありがとうございました", mailbody)

        #戻り値
        return json.dumps({})

    except:
        #エラーメッセージの表示
        import traceback
        err = traceback.format_exc()
        print(err)

        return{
            'statusCode' : 500,
            'header' : {
                'context-type' : 'text/json'
            },
            'body' : json.dumps({
                'error' : '内部エラーが発生しました。'
            })
        }
    
