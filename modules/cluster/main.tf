//
// Defines an ECS cluster with a capacity provider defined by the ARN 
// of the provided autoscaling group.
//

resource "aws_ecs_cluster" "cluster" {
  name = var.name
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "${var.name}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = var.autoscaling_group_arn

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 50
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]
}

output "cluster_id" {
  value = aws_ecs_cluster.cluster.id
}
