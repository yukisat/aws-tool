# ec2-snapshot-tool
### 用途
EBS-SnapShot-Policy.json  
　　実行するのに必要なIAMポリシーです。IAMロールにアタッチして利用してください。  
ec2-snapshot.sh  
　　EC2にアタッチされているEBSのスナップショットを取得できます。  
　　「Key:"Auto_SS" Values:"true"」のタグが付与されます。  
　　※1時間以内に取得している場合は、実行されません  
ec2-delete-snapshot.sh  
　　「Key:"Auto_SS" Values:"true"」のタグが付いているスナップショットを削除します。(デフォルトは3日以前のスナップショットを削除)  
  cronで設定してください。  

### インストール
```
git clone git://github.com/yukisat/ec2-snapshot-tool

tree ~/ec2-snapshot-tool/
----
~/ec2-snapshot-tool/
├── EBS-SnapShot-Policy.json
├── ec2-delete-snapshot.sh
├── ec2-snapshot.sh
└── README.md

0 directories, 4 files
----
```

### ログインした時にスナップショットを自動で取得
Bash の場合
```
vi ~/.bashrc
----
bash ~/ec2-snapshot-tool/ec2-snapshot.sh &
----
```

### cron 設定
crontab -e
----
* * * * * bash ~/ec2-snapshot-tool/ec2-delete-snapshot.sh
----
