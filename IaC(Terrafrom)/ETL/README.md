####Terraform/Codepipelineを使用したコンテナの自動デプロイ####  

【概要】 GitHubにソースコードをデプロイした時に、自動でビルド&デプロイする機能を  
Terraformを使用して実装する。  

【目的】 
1.CI/CDの実装  
2.Terra formの「Standard Module Structure」に準拠したコーディング  
3.GitHubを習得  
4.Codeシリーズの理解  
5.ECS(docker)の理解  
※GitHub Action様のレポジトリには環境変数が入っているため非公開  

【構成図】※2024/12/27追加 最終系は以下の形式にはならなかったです。  
![スクリーンショット 2024-12-26 130627](https://github.com/user-attachments/assets/979a0081-b067-4957-94e8-7f2c25aa1998)   

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
![スクリーンショット 2024-12-27 113200](https://github.com/user-attachments/assets/ec60c50a-aa35-431b-bcb1-132202ad4788)　　

※ECRへのプッシュをトリガーにCloudWatch Eventsにて検知、  
検知後CodepipelineよりCodedeployを使用し、サービス更新。


【実行環境】  
　・OS: Windows11  
　・シェル: GitBash  
　・Terraformバージョン: 1.10.2  

【所感】  
・一通りAWS環境を一通り作成できたと推察される。  
※今回はGitHub Actionを使用し、ECRへのイメージプッシュした状態まで作成し、  
ECRへのプッシュをCloudWatch Eventsによる検知からS3に格納したタスク定義ファイルおよびappspec.yamlから  
Code Deployにてサービスを更新するCode Pipelineを実装。  

ただし、タスク定義ファイルがアカウントIDなどをハードコーディングする必要があるため、  
手段としては下記の中から選択がプロジェクトにおいて使用されるのではないか。  

①CI/CDを全てGitHub Actionを使用  
②CI/CDでソースコードのみをS3に配置し、Code Buildからイメージ作成およびタスク定義を動的に作成  
そこからCode Deployを用いてデプロイ  

・tsstate.lockの実装でapply実行時にロックファイルが作成されるので、  
他のメンバーが同時実行できないように出来る仕組みを取り入れられた。  

・Terraformの使い方をもう少し学習が必要であるため、別途学習が必要  

・アプリを自分で作成できないため、Dockerfileでは簡単なindex.htmlの更新化していないが、  
ゆくゆくはアプリもある程度コンテナの検証や、ビルド/テストのことも考慮して学習が必要。

・Event Bridgeによる実行に、CloudTrailの証跡設定が必要であることに時間を要した。  

・一度、CodepipelineにてCI/CDをすると次回以降タスク定義とALBの設定が、  
tsstateファイルの内容とデグレが発生し、terraform applyがエラーとなる。  
故に、デグレを防ぐ方法や、applyに影響を与えない方法を考える必要がある。  