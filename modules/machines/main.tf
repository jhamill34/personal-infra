//
// The auto scaling group that is responsible for maintaining a 
// desired number of instances of the launch template. These 
// instances will register themselves with the ECS cluster when they come up.
//

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
  instance_type = var.capacity_type

  // TODO: Add the key_name argument
  // key_name = "jhamill-macbook"

  network_interfaces {
    security_groups             = [var.security_group_id]
    associate_public_ip_address = var.public_ip
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
  desired_capacity = var.capacity
  min_size         = var.capacity
  max_size         = var.capacity

  vpc_zone_identifier = var.subnet_ids

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

