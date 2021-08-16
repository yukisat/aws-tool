#!/bin/bash

set -ue

Region=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e 's/.$//'`
MyInstance=`hostname`

export AWS_DEFAULT_REGION=${Region}

EC2_VolumeId=$( \
  aws ec2 describe-instances \
    --filter "Name=tag:Name,Values=${MyInstance}" \
    --query 'Reservations[].Instances[].BlockDeviceMappings[].Ebs[].VolumeId' \
    --output text \
)

aws ec2 create-snapshot --volume-id ${EC2_VolumeId} --tag-specifications 'ResourceType="snapshot",Tags=[{Key="Name",Value='$MyInstance'},{Key="Auto_SS",Value="true"}]' --description "Auto snapshot at root login"
