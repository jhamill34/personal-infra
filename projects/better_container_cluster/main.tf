data "aws_availability_zones" "available" {}

locals {
  subnet_groups = [for subnet in cidrsubnets(var.cidr_block, 8, 8, 8) : cidrsubnets(subnet, 4, 4)]
}

// 1. Create our highlevel VPC with an internet gateway attached 
module "service-vpc" {
  source     = "../../modules/vpc"
  name       = "${var.name}-vpc"
  cidr_block = var.cidr_block
}

// 2. Create 6 subnets (1 private, 1 public) in 3 availability zones
module "service-subnet" {
  count = length(local.subnet_groups)

  source             = "../../modules/subnets"
  name               = "${var.name}-subnet-az-${count.index + 1}"
  availability_zone  = data.aws_availability_zones.available.names[count.index]
  public_cidr_block  = local.subnet_groups[count.index][0]
  private_cidr_block = local.subnet_groups[count.index][1]

  vpc_id                = module.service-vpc.vpc_id
  public_route_table_id = module.service-vpc.public_route_table_id
}

// 3. Define our high level security groups for this VPC
//   - one for the load balancer
//   - one for the web servers
module "service-security-groups" {
  source      = "../../modules/security_groups"
  name_prefix = var.name
  vpc_id      = module.service-vpc.vpc_id
}

// 4. Create an application load balancer and attach it to 
// the public subnets using our loadbalancer security group. 
// this security group allows traffic on port 80 and 443 from anywhere 
// and routes traffic to all ports in the webserver security group
module "service-lb" {
  source            = "../../modules/load_balancer"
  name              = "${var.name}-lb"
  internal          = false
  security_group_id = module.service-security-groups.loadbalancer_sg_id
  subnet_ids        = [for subnet in module.service-subnet : subnet.public_subnet_id]
}

// 4a. Create an internal load balancer for our internal services
module "service-internal-lb" {
  source            = "../../modules/load_balancer"
  name              = "${var.name}-internal-lb"
  internal          = true
  security_group_id = module.service-security-groups.loadbalancer_sg_id
  subnet_ids        = [for subnet in module.service-subnet : subnet.private_subnet_id]
}

// 4b. Create a NAT gateway in each availability zone to allow our instances to talk to ECS
// since we don't assign any public IP address to our instances anymore
module "service-nat" {
  count = length(local.subnet_groups)

  source = "../../modules/nat_gateway"
  name   = "${var.name}-nat-${count.index + 1}"
  vpc_id = module.service-vpc.vpc_id

  private_subnet_id = module.service-subnet[count.index].private_subnet_id
  public_subnet_id  = module.service-subnet[count.index].public_subnet_id
}

// TODO: Create a VPC endpoint so our instances can talk to S3 without going through the NAT gateway

// 5. Create an instance profile for our EC2 instances so that they can talk to ECS
module "services-machine-role" {
  source = "../../modules/service_role"
  name   = "${var.name}-machine-role"
}

// 6. Create an auto scaling group that launches instances into the 
// private subnets and attaches them to the ECS cluster. We also attach the 
// webserver security group so that they only accept traffic from load balancers 
// and create outbound traffic on any port. We do NOT allocate a public IP 
// to our instances, instead they will talk to a NAT gateway.
module "service-machines" {
  source            = "../../modules/machines"
  name_prefix       = var.name
  security_group_id = module.service-security-groups.webserver_sg_id
  subnet_ids        = [for subnet in module.service-subnet : subnet.private_subnet_id]
  instance_profile  = module.services-machine-role.profile_name
  ecs_cluster_name  = "${var.name}-cluster"
  capacity          = length(local.subnet_groups)
  capacity_type     = "t4g.micro"
  public_ip         = false
}

// 7. Create a cluster that our services will run in
module "test-cluster" {
  source                = "../../modules/cluster"
  name                  = "${var.name}-cluster"
  autoscaling_group_arn = module.service-machines.autoscaling_arn
}

//##################################################
// Create a single service definition 
//##################################################

// 8a. Create a service registry for "web"
module "service-registry" {
  source = "../../modules/container_repo"
  name   = "${var.name}-web"
}

// 8b. register the service in ecs
module "service-web-service" {
  source            = "../../modules/service"
  name              = "web"
  cluster_id        = module.test-cluster.cluster_id
  vpc_id            = module.service-vpc.vpc_id
  health_check_path = "/greet"
  instances         = 1
}

resource "aws_alb_listener_rule" "web-service-listener-rule" {
  listener_arn = module.service-lb.listener_arn

  action {
    type             = "forward"
    target_group_arn = module.service-web-service.target_group_arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

// 9a. Create a service registry for internal "app"
module "service-app-registry" {
  source = "../../modules/container_repo"
  name   = "${var.name}-app"
}

// 9b. register the service in ecs
module "service-app-service" {
  source            = "../../modules/service"
  name              = "app"
  cluster_id        = module.test-cluster.cluster_id
  vpc_id            = module.service-vpc.vpc_id
  health_check_path = "/greet"
  instances         = 1
}

resource "aws_alb_listener_rule" "app-service-listener-rule" {
  listener_arn = module.service-internal-lb.listener_arn

  action {
    type             = "forward"
    target_group_arn = module.service-app-service.target_group_arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  condition {
    http_header {
      http_header_name = "X-INTERNAL-SERVICE"
      values           = ["app"]
    }
  }
}
