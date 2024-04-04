variable "count" {
  type = number
}

variable "name_prefix" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "subnet_id" {
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
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "this" {
  count = var.count

  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]

  tags = {
    Name = "${var.name_prefix}-${count.index}"
  }

  ami           = data.aws_ami.this.id
  instance_type = "t4g.micro"
}


