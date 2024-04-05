#!/bin/bash

# Assumes that the image has been built and pushed to ECR using the push.sh script

# Change this to your own prefix
PREFIX="jhamill-service"
SERVICE="web"

ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

function register_task_definition {
  json=$(mktemp) 
  cat >$json
  echo "task definition saved in $json" >&2
  result=$(aws ecs register-task-definition --cli-input-json file://$json --region us-west-2)

  echo $result | jq . >&2
  taskd_arn=$(echo "$result" | jq -r '.taskDefinition.taskDefinitionArn')
  echo $taskd_arn
}

image="$ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/$PREFIX-$SERVICE:latest"

task_arn=$(register_task_definition <<-EOF
{
  "family": "$SERVICE",
  "containerDefinitions": [
    {
      "name": "main",
      "command": ["server"],
      "image": "$image",
      "memoryReservation": 512,
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        },
        {
          "containerPort": 8081,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "healthCheck": {
        "retries": 3,
        "command": ["CMD-SHELL", "curl -f http://localhost:8081/ || exit 1"],
        "timeout": 5,
        "interval": 30,
        "startPeriod": 240
      }
    }
  ]
}
EOF)


echo $task_arn

aws ecs update-service --cluster "$PREFIX-cluster" --service $SERVICE \
  --task-definition $task_arn --force-new-deployment --region us-west-2
