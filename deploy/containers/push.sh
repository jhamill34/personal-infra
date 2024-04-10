#!/bin/bash

# Change this to your own prefix
PREFIX="<your cluster name>"
SERVICES="<space separated service names>"
REGION="us-east-1"

ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

for SERVICE in $SERVICES; do
    echo "Tagging $SERVICE"
    docker tag $PREFIX-$SERVICE:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PREFIX-$SERVICE:latest
    echo "Pushing $SERVICE"
    docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PREFIX-$SERVICE:latest
done
