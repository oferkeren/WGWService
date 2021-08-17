#!/bin/bash
#normalize with dos2unix
# $(. $(dirname $0)/aws/get-deployment-conf-path.sh)
CONF_FILE="no conf file present at then moment"
SANITY_HEALTH_CHECK_TOKEN_NAME=code-deploy-sanity-health-check-token
SANITY_HEALTH_CHECK_TOKEN_LINE=`echo $CONF_FILE | grep $SANITY_HEALTH_CHECK_TOKEN_NAME`
SANITY_HEALTH_CHECK_TOKEN_VALUE=${SANITY_HEALTH_CHECK_TOKEN_LINE//$SANITY_HEALTH_CHECK_TOKEN_NAME = /}
SANITY_HEALTH_CHECK_TOKEN_VALUE=${SANITY_HEALTH_CHECK_TOKEN_VALUE%$'\r'}
echo $SANITY_HEALTH_CHECK_TOKEN_VALUE | tr -d '"'