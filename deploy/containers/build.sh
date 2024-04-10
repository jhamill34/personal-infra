#!/bin/bash

# Change this to your own prefix
PREFIX="<your cluster name>"
SERVICES="<space separated service names>"
LOCATION="java"

for SERVICE in $SERVICES; do
    echo "Building $SERVICE"
    
    ## Change this line to where your services would be located
    cd ${LOCATION}/${SERVICE}

    docker build -t "${PREFIX}-${SERVICE}:latest" . 
    cd ../..
done
