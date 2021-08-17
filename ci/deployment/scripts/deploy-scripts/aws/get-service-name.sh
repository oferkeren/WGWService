#!/bin/bash
#normalize with dos2unix

terminate() { status=$1; shift; echo "FATAL: $*"; exit $status; }
INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || terminate \"wget instance-id has failed: $?\"`"
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')

# Grab tag value
SERVICE=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Service" --region=$REGION --output=text | cut -f5)
echo $SERVICE

