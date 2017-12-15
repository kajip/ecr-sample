# AWS用Dockerイメージ作成プロジェクトの雛形

CodeBuildを用いてECRにDockerイメージをリリースするプロジェクトの雛形

## 構成

* Dockerfile

    Dockerイメージを構築するための設定ファイル

* [cloudformation](cloudformation)

    このイメージを生成するために必要な環境をAWS上に構築するためのCloudFormationテンプレートファイル置き場

## 事前準備

1. AWS CLI のインストール

    pip(pythonのライブラリ管理ツール)を利用してインストールします。
    
    ```bash
    % pip install awscli
    ```

2. AWSの設定

    ホームディレクトリに .awsディレクトリを作成し、そこに config という名前のファイルを作成します。
    
    ```
    [default]
    region = ap-northeast-1
    output = json
    ```

    AWS側でアクセストークンを発行し、ホームディレクトリの.aws/credentials
    
    ```
    [default]
    aws_access_key_id = <<AWSで発行したアクセスキー>>
    aws_secret_access_key = <<AWSで発行したシークレットキー>>
    ```

## 初期構築

1. CloudFormationを実行

    このディレクトリ直下で下記コマンドを実行する

    ```bash
    % aws cloudformation create-stack --stack-name EcrSample --template-body file://./cloudformation/template.yml
    ```

2. CodeCommitのレポジトリにpush

    このプロジェクトをCodeCommitのレポジトリにpushする

    ```bash
    # 始めてgitでCodeCommitを利用するときは、最初にこのコマンドで必要な設定を追加する
    % git config --global credential.helper '!aws codecommit credential-helper $@'
    % git config --global credential.UseHttpPath true
    # macOS環境でCodeCommitを使うと、key-chain-helperが悪さをするので注意
    % git remote add origin https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/ecr-sample
    % git push --all origin
    ```

3. CodeBuildを実行

    CodeBuildを実行し、Dockerイメージを生成する

    ```bash
    % aws codebuild start-build --project-name ecr-sample
    ```

## AWS環境の更新

1. チェンジセットの構築（dry-runの実行）

    既に構築済みのスタックにテンプレートの変更を反映するには、最初にチェンジセットを作成する。

    ```bash
    % aws cloudformation create-change-set --stack-name EcrSample --change-set-name UPDATE --template-body file://./cloudformation/template.yml
    ```

2. チェンジセットの確認

    チェンジセットが作成されたら、下記コマンドでAWS上の変更内容を確認する。Webコンソールの方が見やすいかも。。。

    ```bash
    % aws cloudformation describe-change-set --stack-name EcrSample --change-set-name UPDATE
    {
       ....
        # JSON応答のChangesが変更内容になる
        "ChangeSetName": "UPDATE",
        "Changes": [
            {
                "Type": "Resource",
                "ResourceChange": {
                    "Action": "Add",
                    "LogicalResourceId": "ApplicationLogS3BucketPolicy",
                    ...
                }
            }
        ]
    }
    ```

3. チェンジセットの反映

    問題がなければ、結果を反映させる。
    
    ```bash
    % aws cloudformation execute-change-set --stack-name EcrSample --change-set-name UPDATE
    ```

## AWS環境の削除

1. 破棄

    CloudFormation から設定内容を削除する
    
    ```bash
    % aws cloudformation delete-stack --stack-name EcrSample
    ```
