#!/bin/bash

# Change this to your own prefix
PREFIX="jhamill-service"
SERVICES="web"

for SERVICE in $SERVICES; do
    echo "Building $SERVICE"
    
    ## Change this line to where your services would be located
    cd java/${SERVICE}

    docker build -t "${PREFIX}-${SERVICE}:latest" . 
    cd ../..
done
