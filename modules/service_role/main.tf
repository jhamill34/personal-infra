// 
// Defines a custom role that allows our EC2 instances to make ECS calls 
// which is required for ECS to work. When an EC2 instance is launched that 
// has the ecsAgent this role allows the agent to register the instance with 
// the ECS cluster by adding it to the capacity provider. 
//

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

