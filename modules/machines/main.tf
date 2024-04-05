variable "name_prefix" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "public" {
  type = bool
}

variable "instance_profile" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm*"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = var.name_prefix
  image_id      = data.aws_ami.this.id
  instance_type = "t4g.micro"

  key_name = "jhamill-macbook"

  network_interfaces {
    subnet_id                   = var.subnet_id
    security_groups             = [var.security_group_id]
    associate_public_ip_address = var.public
  }

  iam_instance_profile {
    name = var.instance_profile
  }

  user_data = base64encode(<<EOF
  #!/bin/bash
  echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
  EOF
  )
}

resource "aws_autoscaling_group" "this" {
  desired_capacity = 2
  min_size         = 2
  max_size         = 2

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

output "autoscaling_arn" {
  value = aws_autoscaling_group.this.arn
}
