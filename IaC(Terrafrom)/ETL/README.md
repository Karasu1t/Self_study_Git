####Glueを使用したETL処理####  

【概要】 S3バケットにcsvファイルがPutされたことをトリガーにETL処理を実施し、Dynamo DBのレコードに登録する。

【目的】 
1.Glueを使用したETL  
2.環境ごとにフォルダを切り、moduleから呼び出すtfファイルの構成を学習    

【構成図】  
![Image](https://github.com/user-attachments/assets/aa3231bf-7563-4ae5-826e-99d7ab7f3888)

【実現したいこと】  
以下の流れが出来ること  

1.S3バケットにcsvファイルをPut  
2.S3バケットにPutされた情報をSQSでキューイングし、Lambdaを実行する。   
3.Lambdaから変数を引き渡して、Glueを読み出す。  
4.GlueにてETL処理を実施し、DynamoDBに登録する。   

【実行環境】  
　・OS: Windows11  
　・シェル: GitBash  
　・Terraformバージョン: 1.10.2  

【所感】  
・変数の呼び出し方が難しかった。  
※moduleからmoduleへ変数を引き渡すところに苦労した。完全ではないので、引き続き学習が必要。  
・ETL処理にて、Pythonのboto3について、AWS特有であることから避けていたが、Lambda等を使用する  
サーバレスアーキテクトのトレンドを見ると避けられないので別途身に着ける必要があると感じた。  
