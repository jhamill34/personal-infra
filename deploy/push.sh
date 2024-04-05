#!/bin/bash

# Change this to your own prefix
PREFIX="jhamill-service"
SERVICES="web"

ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com

for SERVICE in $SERVICES; do
    echo "Tagging $SERVICE"
    docker tag $PREFIX-$SERVICE:latest $ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/$PREFIX-$SERVICE:latest
    echo "Pushing $SERVICE"
    docker push $ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/$PREFIX-$SERVICE:latest
done
