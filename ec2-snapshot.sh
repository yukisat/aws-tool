#!/bin/bash

set -ue

Region=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e 's/.$//'`
MyInstance=`hostname`
LOGFILE="/var/log/ec2-snapshot.log"

export AWS_DEFAULT_REGION=${Region}

EC2_VolumeId=$( \
  aws ec2 describe-instances \
    --filter "Name=tag:Name,Values=${MyInstance}" \
    --query 'Reservations[].Instances[].BlockDeviceMappings[].Ebs[].VolumeId' \
    --output text \
)

## 1時間前のスナップショットが存在する場合作成しない
TARGET_DATE=$(date "+%Y-%m-%dT%H:%M" -u -d '-1 hours')
NOW_DATE=$(date "+%Y-%m-%dT%H:%M" -u)

Snapshot=$(aws ec2 describe-snapshots \
  --filters "Name=tag:Auto_SS,Values=true" \
  --region ap-northeast-1 \
  --query "Snapshots[?(StartTime>='$TARGET_DATE') && (StartTime<='$NOW_DATE')].[SnapshotId,StartTime]" \
  --output text | head -n1)

if [ -z "$Snapshot" ]; then
    aws ec2 create-snapshot --volume-id ${EC2_VolumeId} --tag-specifications 'ResourceType="snapshot",Tags=[{Key="Name",Value='$MyInstance'},{Key="Auto_SS",Value="true"}]' --description "Auto snapshot at root login" 2>&1 >> ${LOGFILE}
    echo "Automatic snapshot was performed"
  else
    echo "Automatic snapshot does not run"
fi
