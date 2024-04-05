variable "name" {
  type = string
}

variable "cluster_id" {
  type = string
}

resource "aws_ecs_task_definition" "dummy" {
  family = "dummy"

  container_definitions = <<EOF
[
  {
    "name": "main",
    "image": "arm64v8/debian:bookworm-slim",
    "command": [ "sleep", "inf" ],
    "memory": 10,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 0,
        "protocol": "tcp"
      }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "svc" {
  name = var.name

  lifecycle {
    ignore_changes = [task_definition]
  }

  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.dummy.id
  desired_count   = 1
}
