variable "name" {
  type = string
}

resource "aws_iam_role" "ecs_role" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.ecs_role.json
}

data "aws_iam_policy_document" "ecs_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "ecs_role" {
  name = "${var.name}-profile"
  role = aws_iam_role.ecs_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_role" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

output "role_name" {
  value = aws_iam_role.ecs_role.name
}

output "profile_name" {
  value = aws_iam_instance_profile.ecs_role.name
}
