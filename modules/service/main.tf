variable "name" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "listener_arn" {
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

  load_balancer {
    target_group_arn = aws_alb_target_group.svc.arn
    container_name   = "main"
    container_port   = 8080
  }

  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.dummy.id
  desired_count   = 1
}

resource "aws_alb_target_group" "svc" {
  name     = var.name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/status"
  }
}

resource "aws_alb_listener_rule" "svc" {
  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.svc.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
