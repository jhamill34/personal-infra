//
// Creates a base ECS service that registers the container instances to
// the configured ALB with a rule that forwards to this service based off off 
// the configured path pattern. 
//

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
  desired_count   = var.instances
}

resource "aws_alb_target_group" "svc" {
  name     = var.name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = var.health_check_path
  }
}

