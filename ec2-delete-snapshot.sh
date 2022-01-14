#!/bin/bash

set -ue

Region=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e 's/.$//'`
Delete_Date=$(date "+%Y-%m-%dT%H:%M" -u -d '-3 day')
InstanceId=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

export AWS_DEFAULT_REGION=${Region}

## Auto_SS のタグ付きで3日前のスナップショットは削除
aws ec2 describe-snapshots \
  --filters "Name=tag:Auto_SS_TG,Values=${InstanceId}" \
  --query "Snapshots[?(StartTime<='$Delete_Date')].[SnapshotId]" \
  --output text | \
  xargs -I{} aws ec2 delete-snapshot \
  --snapshot-id {}
