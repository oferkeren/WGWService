#!/bin/bash
#normalize with dos2unix
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


if [["${DEPLOYMENT_VERSION}" != ""]];then
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


aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $DOCKER_REPO
docker pull $DOCKER_REPO$IMAGE_NAME${WGW_images[$DEPLOYMENT_GROUP_NAME]}:$IMAGE_TAG