#!/bin/bash

WORKING_DIR=/home/ubuntu
WGW_LOG_DIRECTORY=$WORKING_DIR/WGW-Logs
WGW_SYSLOG_DIRECTORY=$WORKING_DIR/SIPREC-Logs
REGION=eu-west-1
DOCKER_REPO=366789379256.dkr.ecr.eu-west-1.amazonaws.com/
IMAGE_NAME=wgw_service
IMAGE_TAG=latest
declare -A WGW_images=(\
["WGWServiceFeature"]=_feature \
["WGWServiceDevelopment"]=_dev \
["WGWServiceQA"]=_qa \
["WGWServiceStaging"]=_stage \
["WGWServiceProduction"]= \
["WGWServiceProductionGov"]=_gov \
)

ENV_VALUE=$(echo ${WGW_images[$DEPLOYMENT_GROUP_NAME]} | sed 's/_//')


case "$DEPLOYMENT_GROUP_NAME" in
 "WGWServiceProductionGov" ) aws_creds_volume=-v ~/.aws:/root/.aws ;;
 *) aws_creds_volume="" ;;
esac

if [[ "${DEPLOYMENT_VERSION}" != "" ]];then
    IMAGE_TAG = $DEPLOYMENT_VERSION
fi

if [[ "$DEPLOYMENT_GROUP_NAME" == "WGWServiceProduction" ]]; then
    DOCKER_REPO=924197678267.dkr.ecr.eu-west-1.amazonaws.com
fi

if [[ "$DEPLOYMENT_GROUP_NAME" == "WGWServiceProductionGov" ]]; then
    711704522513.dkr.ecr.us-gov-west-1.amazonaws.com
    REGION=us-gov-west-1
fi

function check_group() {
    if [[ "$DEPLOYMENT_GROUP_NAME" != "WGWServiceFeature" &&
        "$DEPLOYMENT_GROUP_NAME" != "WGWServiceDevelopment" &&
        "$DEPLOYMENT_GROUP_NAME" != "WGWServiceQA" &&
        "$DEPLOYMENT_GROUP_NAME" != "WGWServiceStaging" &&
        "$DEPLOYMENT_GROUP_NAME" != "WGWServiceProduction" &&
        "$DEPLOYMENT_GROUP_NAME" != "WGWServiceProductionGov" \
            ]]; then
        echo "Unknown DEPLOYMENT_GROUP_NAME: $DEPLOYMENT_GROUP_NAME"
        exit 1
    fi
}
check_group

CONF_VERSION="$(. $(dirname $0)/aws/get-conf-version.sh)"

EC2_INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || terminate \"wget instance-id has failed: $?\"`"
EC2_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
SGW_APPLICATION_URL=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$EC2_INSTANCE_ID" "Name=key,Values=sgwUrl" --region=$EC2_REGION --output=text | cut -f5)
WGW_URL=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$EC2_INSTANCE_ID" "Name=key,Values= UrlTag" --region=$EC2_REGION --output=text | cut -f5)
docker run -dit --rm --net=host \
$aws_creds_volume \
--name WGWService \
-v $WGW_LOG_FILE_PATH:$WGW_LOG_FILE_PATH \
-e SGW_URL=$SGW_APPLICATION_URL \
-e WGW_URL=$WGW_URL \
-e DEPLOYMENT_CONF_VERSION=$CONF_VERSION \
-e EC2_ID=$EC2_INSTANCE_ID \
-e JANUS_ENV=$ENV_VALUE \
$DOCKER_REPO$IMAGE_NAME${WGW_images[$DEPLOYMENT_GROUP_NAME]}:$IMAGE_TAG bash