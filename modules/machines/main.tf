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

  network_interfaces {
    subnet_id                   = var.subnet_id
    security_groups             = [var.security_group_id]
    associate_public_ip_address = var.public
  }
}

resource "aws_autoscaling_group" "this" {
  desired_capacity = 2
  min_size         = 2
  max_size         = 2

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}
