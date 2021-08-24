#!/bin/bash

set -ue

Region=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e 's/.$//'`
InstanceId=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
MyInstance=`hostname`
Target_Date=$(date "+%Y-%m-%dT%H:%M" -u -d '-1 hours')
Delete_Date=$(date "+%Y-%m-%dT%H:%M" -u -d '-1 day')
Now_Date=$(date "+%Y-%m-%dT%H:%M" -u)
Log_File="/var/log/ec2-snapshot.log"

export AWS_DEFAULT_REGION=${Region}

## 対象インスタンスのボリュームIDを取得
EC2_VolumeId=$( \
  aws ec2 describe-instances \
    --instance-id ${InstanceId} \
    --query 'Reservations[].Instances[].BlockDeviceMappings[].Ebs[].VolumeId' \
    --output text )
## 配列へ格納
EC2_VolumeIds=(`echo $EC2_VolumeId`)

## スナップショットの作成 (1時間以内にスナップショットが存在する場合作成しない)
Snapshot=$(aws ec2 describe-snapshots \
  --filters "Name=tag:Auto_SS,Values=true" \
  --region ap-northeast-1 \
  --query "Snapshots[?(StartTime>='$Target_Date') && (StartTime<='$Now_Date')].[SnapshotId,StartTime]" \
  --output text | head -n1)

if [ -z "$Snapshot" ]; then
    for VolumeId in ${EC2_VolumeIds[@]}; do
      aws ec2 create-snapshot --volume-id ${VolumeId} --tag-specifications 'ResourceType="snapshot",Tags=[{Key="Name",Value='$MyInstance'},{Key="Auto_SS",Value="true"}]' --description "Auto snapshot at root login" 2>&1 >> ${Log_File}
    done
    echo "Automatic snapshot was performed"
  else
    echo "Automatic snapshot does not run"
fi
