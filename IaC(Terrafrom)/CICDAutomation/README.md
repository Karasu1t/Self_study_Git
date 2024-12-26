####Terraform/Codepipelineを使用したコンテナの自動デプロイ####  

【概要】 GitHubにイメージをデプロイした時に、自動でビルド&デプロイする機能を  
Terraformを使用して実装する。  

【目的】 
1.CI/CDの実装  
2.Terra formの「Standard Module Structure」に準拠したコーディング  
3.GitHubを習得  
4.Codeシリーズの理解  
5.ECS(docker)の理解  


【構成図】  
![スクリーンショット 2024-12-20 095126](https://github.com/user-attachments/assets/c0fe48ca-da39-4c8c-821b-2cd2170238c9)  

【実現したいこと】  
以下の流れが出来ること  

1.GitHubへのソースファイルプッシュ    
2.ECRレポジトリへのプッシュをトリガーにCodePipelineを発動  
3.CodePipeline上でBlue/Greenデプロイを実施し、ロールバックの可否の状態を構成  
4.手動でデプロイorロールバックを実施[手動対応]  

ただし、全量を一気に実現するスキルが12/19時点で私に何ため、以下の順で実装を検討する。  
※管理コンソール上での構築は学習済  

①クライアント端末からALBを介し、コンテナを自動起動まで  
※tsstateファイルは手動で作成済のS3バケットに格納  

【構成図】  
![スクリーンショット 2024-12-20 095342](https://github.com/user-attachments/assets/d5827123-8697-458d-af08-ef93d765c258)  

②ALBとCode Deployを使用したBlue/Greenデプロイを実装  

【構成図】  
![スクリーンショット 2024-12-20 095745](https://github.com/user-attachments/assets/726fb98b-4494-49d7-84e2-469204c5ca93)  

③GitHubレポジトリにDockerFileなどのソースファイルをイメージをECRレポジトリにプッシュ後に、  
Code Pipeline(Code Build,Code Deploy)にて自動リリース  

【構成図】  
![image](https://github.com/user-attachments/assets/67a137fb-db0c-4fd7-a38a-0db11fc2d52f)  

※ECRへのプッシュをトリガーにCloudWatch Eventsにて検知、  
検知後Codepipelineを使用してCodedeployを使用し、サービス更新を構想しているが、  
うまくいかず滞り中。

